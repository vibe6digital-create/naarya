import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/emergency_contact_model.dart';
import 'firebase_auth_service.dart';

class EmergencyContactService {
  static FirebaseFirestore? _firestoreInstance;

  static FirebaseFirestore? get _firestore {
    try {
      _firestoreInstance ??= FirebaseFirestore.instance;
      return _firestoreInstance;
    } catch (_) {
      return null;
    }
  }

  static bool get isAvailable =>
      _firestore != null && FirebaseAuthService.currentUser?.uid != null;

  static CollectionReference<Map<String, dynamic>>? collectionRef() {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null || _firestore == null) return null;
    return _firestore!
        .collection('users')
        .doc(uid)
        .collection('emergencyContacts');
  }

  /// Returns a live stream of the user's emergency contacts ordered by creation time.
  static Stream<List<EmergencyContact>> watchContacts() {
    final ref = collectionRef();
    if (ref == null) return Stream.value([]);
    return ref
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                EmergencyContact.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Adds a new contact. Firestore generates the document ID.
  static Future<void> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    final ref = collectionRef();
    if (ref == null) return;
    try {
      await ref.add({
        'name': name,
        'phone': phone,
        'relation': relation,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[EmergencyContactService] addContact error: $e');
      rethrow;
    }
  }

  /// Deletes the contact with the given document ID.
  static Future<void> deleteContact(String id) async {
    final ref = collectionRef();
    if (ref == null) return;
    try {
      await ref.doc(id).delete();
    } catch (e) {
      debugPrint('[EmergencyContactService] deleteContact error: $e');
      rethrow;
    }
  }
}
