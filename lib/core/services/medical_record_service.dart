import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/medical_record_model.dart';
import 'firebase_auth_service.dart';

/// Firestore structure:
///
///   users (collection)
///   └── {uid} (document)
///         └── health_vault (subcollection)
///               └── {recordId} (document)
///                     ├── id, title, type, doctor, hospital
///                     ├── date, fileUrl, fileType, storagePath
///                     ├── tags[], notes
///                     ├── createdAt, updatedAt
///                     └── healthDetails (map, optional)
///
/// ── Firestore Security Rules ─────────────────────────────────────────────
///
///   rules_version = '2';
///   service cloud.firestore {
///     match /databases/{database}/documents {
///       match /users/{userId}/health_vault/{recordId} {
///         allow read, write: if request.auth != null
///                            && request.auth.uid == userId;
///       }
///     }
///   }
///
/// ─────────────────────────────────────────────────────────────────────────

class MedicalRecordService {
  static FirebaseStorage? get _storage {
    try { return FirebaseStorage.instance; } catch (_) { return null; }
  }

  // ─── Collection reference ─────────────────────────────────────────────────

  /// users/{uid}/health_vault
  static CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('health_vault');

  // ─── Storage helpers ──────────────────────────────────────────────────────

  /// Uploads a single image and returns (downloadUrl, storagePath).
  static Future<(String, String)?> uploadImage({
    required XFile image,
    required String recordId,
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    final storage = _storage;
    if (storage == null) return null;

    final ext = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : 'jpg';
    final storagePath = 'users/$userId/health_vault/$recordId/file.$ext';
    final ref = storage.ref().child(storagePath);

    final bytes = await image.readAsBytes();
    final task = ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/$ext'),
    );
    task.snapshotEvents.listen((s) {
      if (s.totalBytes > 0) onProgress?.call(s.bytesTransferred / s.totalBytes);
    });
    await task;
    final url = await ref.getDownloadURL();
    return (url, storagePath);
  }

  /// Uploads a document (PDF/DOC) and returns (downloadUrl, storagePath).
  static Future<(String, String)?> uploadDocument({
    required PlatformFile file,
    required String recordId,
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    final storage = _storage;
    if (storage == null) return null;

    final ext = file.extension?.toLowerCase() ?? 'pdf';
    final storagePath = 'users/$userId/health_vault/$recordId/file.$ext';
    final ref = storage.ref().child(storagePath);

    Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      return null;
    }

    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: 'application/$ext'),
    );
    task.snapshotEvents.listen((s) {
      if (s.totalBytes > 0) onProgress?.call(s.bytesTransferred / s.totalBytes);
    });
    await task;
    final url = await ref.getDownloadURL();
    return (url, storagePath);
  }

  // ─── Firestore CRUD ───────────────────────────────────────────────────────

  /// Save or overwrite a record.
  static Future<void> saveRecord(MedicalRecord record) async {
    final userId = record.userId ?? FirebaseAuthService.currentUser?.uid ?? 'anonymous';
    await _collection(userId).doc(record.id).set(record.toFirestore());
  }

  /// Live stream — only returns records belonging to the signed-in user.
  static Stream<List<MedicalRecord>> recordsStream() {
    final userId = FirebaseAuthService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(MedicalRecord.fromFirestore).toList());
  }

  /// Delete a record — removes the Storage file and Firestore document.
  static Future<void> deleteRecord(MedicalRecord record) async {
    final userId = record.userId ?? FirebaseAuthService.currentUser?.uid;
    if (userId == null) return;

    // Delete file from Storage
    if (record.storagePath != null) {
      try {
        await _storage?.ref().child(record.storagePath!).delete();
      } catch (_) {}
    }

    await _collection(userId).doc(record.id).delete();
  }
}
