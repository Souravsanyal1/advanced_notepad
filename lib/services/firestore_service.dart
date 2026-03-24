import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class FirestoreService {
  final CollectionReference _notesCollection = FirebaseFirestore.instance
      .collection('notes');

  Stream<List<Note>> getNotes() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
        });
  }

  Future<void> addNote(Note note) {
    return _notesCollection.add(note.toFirestore());
  }

  Future<void> updateNote(Note note) {
    return _notesCollection.doc(note.id).update(note.toFirestore());
  }

  Future<void> deleteNote(String id) {
    return _notesCollection.doc(id).delete();
  }
}
