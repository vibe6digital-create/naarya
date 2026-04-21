import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore structure:
///
///   travelPartners (collection)
///   └── {partnerId} (document)
///         ├── name        : string   — "MakeMyTrip"
///         ├── category    : string   — "flights"
///         ├── description : string   — short description
///         ├── logoUrl     : string?  — Firebase Storage download URL
///         ├── websiteUrl  : string?  — partner website link
///         ├── order       : number   — display order
///         ├── isActive    : bool     — set false to hide without deleting
///         └── createdAt   : timestamp

class TravelPartnerModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? logoUrl;
  final String? websiteUrl;
  final int order;

  const TravelPartnerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.logoUrl,
    this.websiteUrl,
    this.order = 0,
  });

  factory TravelPartnerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TravelPartnerModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? '',
      description: d['description'] ?? '',
      logoUrl: d['logoUrl'],
      websiteUrl: d['websiteUrl'],
      order: (d['order'] ?? 0 as num).toInt(),
    );
  }
}
