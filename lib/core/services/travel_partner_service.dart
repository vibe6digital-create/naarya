import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/travel_partner_model.dart';

class TravelPartnerService {
  TravelPartnerService._();

  static Stream<List<TravelPartnerModel>> partnersStream() {
    return FirebaseFirestore.instance
        .collection('travelPartners')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(TravelPartnerModel.fromFirestore).toList();
          list.sort((a, b) => a.order.compareTo(b.order));
          return list;
        });
  }
}
