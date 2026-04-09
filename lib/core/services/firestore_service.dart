import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static FirebaseFirestore? _instance;

  static FirebaseFirestore? get _firestore {
    try {
      _instance ??= FirebaseFirestore.instance;
      return _instance;
    } catch (_) {
      return null;
    }
  }

  static const _usersCollection = 'users';

  /// Saves or updates the authenticated user's profile in Firestore.
  ///
  /// Document path: users/{uid}
  /// Uses merge so fields written during onboarding (city, healthGoal, etc.)
  /// are never overwritten by a subsequent login.
  ///
  /// - [phone]: supply for phone-auth users (Firebase User.phoneNumber is
  ///   already set for phone auth, but pass it as a fallback for auto-verified flows)
  /// - [city]: supply only when available at login time (phone auth collects it)
  static Future<void> saveOrUpdateUser(
    User firebaseUser, {
    String? phone,
    String? city,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;

    final docRef = firestore.collection(_usersCollection).doc(firebaseUser.uid);

    try {
      final doc = await docRef.get();

      final providerId = firebaseUser.providerData.isNotEmpty
          ? firebaseUser.providerData.first.providerId
          : 'unknown';

      // These fields are always written / refreshed on every login
      final data = <String, dynamic>{
        'uid': firebaseUser.uid,
        'name': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'phone': firebaseUser.phoneNumber ?? phone ?? '',
        'photoUrl': firebaseUser.photoURL ?? '',
        'authProvider': providerId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!doc.exists) {
        // First-time user — set createdAt and any available onboarding seed data
        data['createdAt'] = FieldValue.serverTimestamp();
        data['age'] = 0;
        data['healthGoal'] = '';
        data['onboardingDone'] = false;
        if (city != null && city.isNotEmpty) {
          data['city'] = city;
        } else {
          data['city'] = '';
        }
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      // Non-fatal — never block the auth flow for a Firestore write failure
      debugPrint('[FirestoreService] saveOrUpdateUser error: $e');
    }
  }

  /// Fetches the current user's Firestore document.
  /// Returns null if not found or Firestore is unavailable.
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final firestore = _firestore;
    if (firestore == null) return null;

    try {
      final doc = await firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('[FirestoreService] getUser error: $e');
      return null;
    }
  }

  /// Partially updates user fields. Use this during onboarding to persist
  /// city, age, healthGoal, onboardingDone, etc.
  static Future<void> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    final firestore = _firestore;
    if (firestore == null) return;

    try {
      await firestore.collection(_usersCollection).doc(uid).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FirestoreService] updateUserFields error: $e');
    }
  }
}
