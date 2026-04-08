import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/todo_item_model.dart';
import 'firebase_auth_service.dart';

class FirestoreNotesService {
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
    return _firestore!.collection('users').doc(uid).collection('notes');
  }

  static Future<List<TodoItem>> loadNotes() async {
    final ref = collectionRef();
    if (ref == null) return [];

    final snapshot = await ref.get();
    return snapshot.docs.map((doc) => TodoItem.fromJson(doc.data())).toList();
  }

  static Future<void> addNote(TodoItem note) async {
    final ref = collectionRef();
    if (ref == null) return;
    await ref.doc(note.id).set(note.toJson());
  }

  static Future<void> updateNote(TodoItem note) async {
    final ref = collectionRef();
    if (ref == null) return;
    await ref.doc(note.id).update(note.toJson());
  }

  static Future<void> deleteNote(String noteId) async {
    final ref = collectionRef();
    if (ref == null) return;
    await ref.doc(noteId).delete();
  }
}
