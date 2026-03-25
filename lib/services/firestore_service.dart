import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'notes';

  // Sync a single note to Firestore
  Future<void> syncNote(Note note) async {
    try {
      await _db.collection(collection).doc(note.id).set(note.toFirestore());
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String id) async {
    try {
      await _db.collection(collection).doc(id).delete();
    } catch (e) {
      debugPrint('Delete sync error: $e');
    }
  }

  // Get all notes (for initial cloud-to-local sync if needed)
  Stream<List<Note>> getNotes() {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }
}
