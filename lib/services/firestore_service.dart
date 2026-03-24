import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class FirestoreService {
  final CollectionReference _notesCollection = FirebaseFirestore.instance
      .collection('notes');
  final CollectionReference _labelsCollection = FirebaseFirestore.instance
      .collection('labels');

   Stream<List<Note>> getNotes({String? label, bool? isArchived, bool? isDeleted, bool? isFavorite}) {
    Query query = _notesCollection.orderBy('updatedAt', descending: true);
    
    if (label != null) {
      query = query.where('labels', arrayContains: label);
    }
    if (isArchived != null) {
      query = query.where('isArchived', isEqualTo: isArchived);
    }
    if (isDeleted != null) {
      query = query.where('isDeleted', isEqualTo: isDeleted);
    }
    if (isFavorite != null) {
      query = query.where('isFavorite', isEqualTo: isFavorite);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  Future<void> moveToTrash(String id) {
    return _notesCollection.doc(id).update({'isDeleted': true, 'isPinned': false});
  }

  Future<void> restoreFromTrash(String id) {
    return _notesCollection.doc(id).update({'isDeleted': false});
  }


  // Label Operations
  Stream<List<String>> getLabels() {
    return _labelsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.get('name') as String).toList();
    });
  }

  Future<void> addLabel(String name) async {
    // Check if label already exists
    final existing = await _labelsCollection.where('name', isEqualTo: name).get();
    if (existing.docs.isEmpty) {
      await _labelsCollection.add({'name': name});
    }
  }

  Future<void> deleteLabel(String name) async {
    final docs = await _labelsCollection.where('name', isEqualTo: name).get();
    for (var doc in docs.docs) {
      await doc.reference.delete();
    }
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

  Stream<int> getNoteCount() {
    return _notesCollection.where('isDeleted', isEqualTo: false).snapshots().map((snapshot) => snapshot.size);
  }
}
