import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/doctor_model.dart';

/// Queries the "instructors" Firestore collection and filters by specialty.
///
/// Returns [DoctorModel] so all existing expert UI cards work without change.
///
/// Firestore structure:
///   instructors (collection)
///   └── {id}
///         ├── name           : string
///         ├── specialties    : string[]  — e.g. ["Yoga", "Garbh Sanskar"]
///         ├── about          : string
///         ├── degree         : string
///         ├── experience     : string
///         ├── photoUrl       : string
///         ├── availableDays  : string[]
///         ├── availableSlots : string[]
///         ├── mode           : "online" | "offline" | "both"
///         ├── whatsappNumber : string
///         ├── order          : int      — sort order
///         └── isActive       : bool
class InstructorService {
  InstructorService._();

  /// Stream of active instructors filtered by a single [specialty].
  ///
  /// Filtering is done client-side with case-insensitive, substring matching
  /// so "Mental Health", "mental health", "mental health expert" all resolve
  /// correctly regardless of how the data is stored in Firestore.
  static Stream<List<DoctorModel>> instructorsStream(String specialty) {
    final normalized = specialty.trim().toLowerCase();
    return FirebaseFirestore.instance
        .collection('instructors')
        .snapshots()
        .map((snap) {
          // isActive filtered client-side: missing field treated as active,
          // only explicitly isActive==false is excluded.
          final active = snap.docs.where((doc) {
            final d = doc.data();
            return d['isActive'] != false;
          });
          final all = active.map(_fromDoc).toList();
          if (normalized.isEmpty) return all;
          return all.where((doc) => doc.specialties.any(
            (s) => s.trim().toLowerCase().contains(normalized),
          )).toList();
        });
  }

  /// Stream of active instructors matching ANY of the given [specialties].
  ///
  /// Filtering is done client-side with case-insensitive, substring matching.
  static Stream<List<DoctorModel>> instructorsStreamMulti(
      List<String> specialties) {
    final normalizedList =
        specialties.map((s) => s.trim().toLowerCase()).toList();
    return FirebaseFirestore.instance
        .collection('instructors')
        .snapshots()
        .map((snap) {
          final active = snap.docs.where((doc) {
            final d = doc.data();
            return d['isActive'] != false;
          });
          final all = active.map(_fromDoc).toList();
          if (normalizedList.isEmpty) return all;
          return all.where((doc) => doc.specialties.any(
            (s) => normalizedList.any(
              (n) => s.trim().toLowerCase().contains(n),
            ),
          )).toList();
        });
  }

  static DoctorModel _fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      degree: d['degree'] as String? ?? d['experience'] as String? ?? '',
      specialties: List<String>.from(d['specialties'] ?? []),
      about: d['about'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      availableDays: List<String>.from(d['availableDays'] ?? []),
      availableSlots: List<String>.from(d['availableSlots'] ?? []),
      mode: ConsultMode.values.firstWhere(
        (m) => m.name == (d['mode'] as String? ?? ''),
        orElse: () => ConsultMode.both,
      ),
      whatsappNumber: d['whatsappNumber'] as String? ?? '',
      cities: List<String>.from(d['cities'] ?? []),
    );
  }
}
