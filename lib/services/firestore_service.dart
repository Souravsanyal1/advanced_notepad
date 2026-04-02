import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name for notes
  static const String notesCollection = 'notes';
  static const String usersCollection = 'users';

  // Get current user's note collection reference
  CollectionReference? get _userNotes {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection(usersCollection).doc(user.uid).collection(notesCollection);
  }

  // Generate a unique ID for a new note
  String generateId() => _db.collection(notesCollection).doc().id;

  // Sync a single note to Firestore
  Future<void> syncNote(Note note) async {
    try {
      final userNotes = _userNotes;
      if (userNotes == null) return; // No user logged in

      await userNotes.doc(note.id).set(note.toFirestore());
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String id) async {
    try {
      final userNotes = _userNotes;
      if (userNotes == null) return;
      
      await userNotes.doc(id).delete();
    } catch (e) {
      debugPrint('Delete sync error: $e');
    }
  }

  // Get all notes (for initial cloud-to-local sync if needed)
  Stream<List<Note>> getNotes() {
    final userNotes = _userNotes;
    if (userNotes == null) return Stream.value([]);
    
    return userNotes.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }
}
