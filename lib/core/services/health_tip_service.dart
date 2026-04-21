import 'package:cloud_firestore/cloud_firestore.dart';

class HealthTip {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String category;
  final String phase;
  final int order;

  const HealthTip({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.category,
    required this.phase,
    required this.order,
  });

  factory HealthTip.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HealthTip(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      category: d['category'] as String? ?? 'general',
      phase: d['phase'] as String? ?? 'all',
      order: (d['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class HealthTipService {
  HealthTipService._();

  static Stream<List<HealthTip>> tipsStream() {
    return FirebaseFirestore.instance
        .collection('healthTips')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(HealthTip.fromFirestore).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }
}
