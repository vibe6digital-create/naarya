import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/expert_model.dart';

/// Combines the "doctors", "instructors", and "lawyers" Firestore collections
/// into a single real-time stream of [ExpertModel] objects.
///
/// Each collection uses its own relevant field for filtering:
///   doctors     → specialties (array)
///   instructors → specialties (array)
///   lawyers     → courts + cities (arrays, merged into specialties)
///
/// Smart routing:
///   category contains "legal" or "law" → includes lawyers collection
///   all other categories               → doctors + instructors only
///
/// No existing service or screen is modified.
class ExpertService {
  ExpertService._();

  static final _firestore = FirebaseFirestore.instance;

  // ── Raw collection streams ─────────────────────────────────────────────────

  // isActive is filtered client-side across all collections:
  // missing field → treated as active; only explicit false → excluded.
  static bool _isActive(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return d['isActive'] != false;
  }

  static Stream<List<ExpertModel>> _doctorsStream() {
    return _firestore
        .collection('doctors')
        .snapshots()
        .map((snap) => snap.docs
            .where(_isActive)
            .map(ExpertModel.fromDoctorDoc)
            .toList());
  }

  static Stream<List<ExpertModel>> _instructorsStream() {
    return _firestore
        .collection('instructors')
        .snapshots()
        .map((snap) => snap.docs
            .where(_isActive)
            .map(ExpertModel.fromInstructorDoc)
            .toList());
  }

  static Stream<List<ExpertModel>> _lawyersStream() {
    return _firestore
        .collection('lawyers')
        .snapshots()
        .map((snap) => snap.docs
            .where(_isActive)
            .map(ExpertModel.fromLawyerDoc)
            .toList());
  }

  // ── Stream combiner (combineLatest semantics, pure Dart) ──────────────────

  /// Merges two streams: emits a new combined list whenever either emits,
  /// after both have emitted at least once.
  static Stream<List<ExpertModel>> _combine(
    Stream<List<ExpertModel>> s1,
    Stream<List<ExpertModel>> s2,
  ) {
    late StreamController<List<ExpertModel>> controller;
    List<ExpertModel>? latest1;
    List<ExpertModel>? latest2;
    StreamSubscription<List<ExpertModel>>? sub1;
    StreamSubscription<List<ExpertModel>>? sub2;

    void emit() {
      if (latest1 != null && latest2 != null) {
        controller.add([...latest1!, ...latest2!]);
      }
    }

    controller = StreamController<List<ExpertModel>>.broadcast(
      onListen: () {
        sub1 = s1.listen(
          (data) { latest1 = data; emit(); },
          onError: controller.addError,
        );
        sub2 = s2.listen(
          (data) { latest2 = data; emit(); },
          onError: controller.addError,
        );
      },
      onCancel: () {
        sub1?.cancel();
        sub2?.cancel();
      },
    );

    return controller.stream;
  }

  /// Chains multiple streams using [_combine] pairwise.
  static Stream<List<ExpertModel>> _combineAll(
    List<Stream<List<ExpertModel>>> streams,
  ) {
    if (streams.isEmpty) return Stream.value([]);
    if (streams.length == 1) return streams[0];
    var result = streams[0];
    for (var i = 1; i < streams.length; i++) {
      result = _combine(result, streams[i]);
    }
    return result;
  }

  // ── Normalize helper ───────────────────────────────────────────────────────

  static List<String> _normalize(List<dynamic> arr) {
    return arr.map((e) => e.toString().trim().toLowerCase()).toList();
  }

  // ── Category → keyword mapping ─────────────────────────────────────────────

  static const Map<String, List<String>> _categoryKeywords = {
    'Mental Fitness':    ['mental health', 'mind', 'therapy'],
    'Physical Fitness':  ['yoga', 'fitness', 'postnatal fitness'],
    'Garbh Sanskar':     ['garbh sanskar', 'prenatal'],
    'Consult Doctor':    ['doctor', 'medical'],
    'Safety & Legal':    ['law', 'legal', 'court'],
  };

  /// Returns a real-time stream filtered by all keywords mapped to [category].
  ///
  /// Falls back to using [category] itself as the sole keyword when no mapping
  /// exists (covers chip-level categories like "Yoga", "Walking", etc.).
  ///
  /// Lawyers are included automatically when any keyword contains "law" or "legal".
  static Stream<List<ExpertModel>> expertsStreamForCategory(String category) {
    final keywords = (_categoryKeywords[category] ?? [category.toLowerCase()])
        .map((k) => k.trim().toLowerCase())
        .toList();

    final isLegalCategory =
        keywords.any((k) => k.contains('legal') || k.contains('law'));

    final Stream<List<ExpertModel>> source = isLegalCategory
        ? _combineAll([_doctorsStream(), _instructorsStream(), _lawyersStream()])
        : _combine(_doctorsStream(), _instructorsStream());

    return source.map((experts) => experts.where((expert) {
          if (expert.type == 'doctor') {
            // Doctors: match only if their `card` field equals the category.
            return expert.card.toLowerCase() == category.toLowerCase();
          }
          // Instructors / lawyers: keep existing keyword-based filtering.
          return keywords.any(
            (kw) => expert.specialties.any((s) => s.contains(kw)),
          );
        }).toList());
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns a combined, real-time stream applying per-collection filter logic.
  ///
  /// * [specialty]  — category string (case-insensitive, substring match).
  ///                  If null/empty, all active experts are returned.
  /// * [typeFilter] — `"doctor"`, `"instructor"`, or `"lawyer"` to restrict
  ///                  to one collection.
  ///
  /// Smart routing:
  ///   specialty contains "legal" or "law" → adds lawyers to results
  ///   all other specialties               → doctors + instructors only
  static Stream<List<ExpertModel>> expertsStream({
    String? specialty,
    String? typeFilter,
  }) {
    final category = (specialty ?? '').trim().toLowerCase();
    final isLegalCategory =
        category.contains('legal') || category.contains('law');

    // Determine which collections to combine
    final Stream<List<ExpertModel>> source;
    if (typeFilter == 'doctor') {
      source = _doctorsStream();
    } else if (typeFilter == 'instructor') {
      source = _instructorsStream();
    } else if (typeFilter == 'lawyer') {
      source = _lawyersStream();
    } else if (isLegalCategory) {
      // Legal category: include all three collections
      source = _combineAll([
        _doctorsStream(),
        _instructorsStream(),
        _lawyersStream(),
      ]);
    } else {
      // Default: doctors + instructors only
      source = _combine(_doctorsStream(), _instructorsStream());
    }

    // Apply per-collection client-side filtering
    if (category.isNotEmpty) {
      return source.map((experts) {
        return experts.where((expert) {
          if (expert.type == 'doctor') {
            // Doctors: match only by `card` field.
            return expert.card.toLowerCase() == category;
          }
          if (expert.type == 'lawyer') {
            // Lawyers: courts + cities already merged into specialties
            return expert.specialties.isNotEmpty &&
                expert.specialties.any((s) => s.contains(category));
          }
          // Instructors: filter by specialties
          return expert.specialties.any((s) => s.contains(category));
        }).toList();
      });
    }

    return source;
  }

  /// One-shot fetch — fetches all relevant collections in parallel.
  ///
  /// Smart routing applies: lawyers are only included when [specialty]
  /// contains "legal" or "law".
  static Future<List<ExpertModel>> fetchExperts({String? specialty}) async {
    final category = (specialty ?? '').trim().toLowerCase();
    final isLegalCategory =
        category.contains('legal') || category.contains('law');

    final queries = <Future<QuerySnapshot>>[
      _firestore.collection('doctors').where('isActive', isEqualTo: true).get(),
      _firestore.collection('instructors').where('isActive', isEqualTo: true).get(),
    ];
    if (isLegalCategory || category.isEmpty) {
      queries.add(
        _firestore.collection('lawyers').where('isActive', isEqualTo: true).get(),
      );
    }

    final results = await Future.wait(queries);

    final doctors = results[0].docs.map(ExpertModel.fromDoctorDoc).toList();
    final instructors = results[1].docs.map(ExpertModel.fromInstructorDoc).toList();
    final lawyers = results.length > 2
        ? results[2].docs.map(ExpertModel.fromLawyerDoc).toList()
        : <ExpertModel>[];

    final combined = [...doctors, ...instructors, ...lawyers];

    if (category.isEmpty) return combined;

    return combined.where((expert) {
      if (expert.type == 'doctor') {
        return expert.card.toLowerCase() == category;
      }
      final tags = _normalize(expert.specialties);
      return tags.any((s) => s.contains(category));
    }).toList();
  }
}
