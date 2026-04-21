import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/expert_video_model.dart';

/// Streams the "expertVideos" collection from Firestore.
/// Only returns documents where isActive == true, sorted by "order".
class ExpertVideoService {
  ExpertVideoService._();

  static Stream<List<ExpertVideoModel>> videosStream() {
    return FirebaseFirestore.instance
        .collection('expertVideos')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map(ExpertVideoModel.fromFirestore)
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }
}
