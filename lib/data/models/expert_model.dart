import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified model representing a doctor, instructor, or lawyer.
///
/// Used by [ExpertService] to combine multiple Firestore collections into a
/// single filterable list.
///
/// The [type] field distinguishes the source collection:
///   "doctor"     — from the "doctors" collection     (filtered by specialties)
///   "instructor" — from the "instructors" collection (filtered by specialties)
///   "lawyer"     — from the "lawyers" collection     (filtered by courts/cities)
class ExpertModel {
  final String id;
  final String name;
  final String type; // "doctor" or "instructor"
  final List<String> specialties;
  final String experience; // maps to `degree` for doctors
  final String about;
  final String? photoUrl;

  const ExpertModel({
    required this.id,
    required this.name,
    required this.type,
    required this.specialties,
    required this.experience,
    required this.about,
    this.photoUrl,
  });

  /// Creates an [ExpertModel] from a Firestore document in the "doctors"
  /// collection.  The `degree` field is used as [experience].
  factory ExpertModel.fromDoctorDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    List<String> specialties;
    if (d['specialties'] != null) {
      specialties = (d['specialties'] as List)
          .map((e) => e.toString().trim().toLowerCase())
          .toList();
    } else if (d['specialty'] != null) {
      specialties = [(d['specialty'] as String).trim().toLowerCase()];
    } else {
      specialties = [];
    }

    return ExpertModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      type: 'doctor',
      specialties: specialties,
      experience: d['degree'] as String? ?? d['experience'] as String? ?? '',
      about: d['about'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
    );
  }

  /// Creates an [ExpertModel] from a Firestore document in the "instructors"
  /// collection.  The `experience` field (or `degree`) is used as [experience].
  factory ExpertModel.fromInstructorDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return ExpertModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      type: 'instructor',
      specialties: ((d['specialties'] as List?) ?? [])
          .map((e) => e.toString().trim().toLowerCase())
          .toList(),
      experience: d['experience'] as String? ?? d['degree'] as String? ?? '',
      about: d['about'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
    );
  }

  /// Creates an [ExpertModel] from a Firestore document in the "lawyers"
  /// collection. The [courts] and [cities] arrays are merged into [specialties]
  /// so the same [hasSpecialty] filtering works uniformly.
  factory ExpertModel.fromLawyerDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Merge courts + cities into a single normalized specialties list
    final courts = ((d['courts'] as List?) ?? [])
        .map((e) => e.toString().trim().toLowerCase())
        .toList();
    final cities = ((d['cities'] as List?) ?? [])
        .map((e) => e.toString().trim().toLowerCase())
        .toList();
    final merged = {...courts, ...cities}.toList(); // deduplicate

    return ExpertModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      type: 'lawyer',
      specialties: merged,
      experience: d['experience'] as String? ?? d['degree'] as String? ?? '',
      about: d['about'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
    );
  }

  /// Returns true if any of this expert's specialties contain [category].
  /// [specialties] is already normalized (lowercase+trimmed) at parse time.
  bool hasSpecialty(String category) {
    final normalized = category.trim().toLowerCase();
    // ignore: avoid_print
    print('CATEGORY: $normalized | TYPE: $type | SPECIALTIES: $specialties');
    return specialties.any((s) => s.contains(normalized));
  }

  /// Returns true if this expert is a lawyer whose courts/cities are non-empty.
  bool get isLawyer => type == 'lawyer';
}
