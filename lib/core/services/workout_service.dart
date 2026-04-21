import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/workout_model.dart';

/// Reads the "workouts" top-level collection from Firestore.
/// Only returns documents where isActive == true, sorted by the
/// "order" field (ascending).
///
/// Admin panel: add / edit workouts directly in the Firebase Console
/// under the "workouts" collection. See WorkoutModel for the full schema.
class WorkoutService {
  WorkoutService._();

  static Stream<List<WorkoutModel>> workoutsStream() {
    return FirebaseFirestore.instance
        .collection('workouts')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map(WorkoutModel.fromFirestore)
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }
}
