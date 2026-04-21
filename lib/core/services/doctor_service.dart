import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/doctor_model.dart';

/// Reads the "doctors" top-level collection from Firestore.
/// Only returns documents where isActive == true.
///
/// Admin panel: add / edit doctors directly in the Firebase Console
/// under the "doctors" collection. See DoctorModel for the full schema.
class DoctorService {
  DoctorService._();

  static Stream<List<DoctorModel>> doctorsStream() {
    return FirebaseFirestore.instance
        .collection('doctors')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(DoctorModel.fromFirestore).toList());
  }
}
