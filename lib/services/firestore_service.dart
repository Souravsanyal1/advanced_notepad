import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
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


  // Label Operations (Dynamic & Combined)
  Stream<List<String>> getLabels() {
    final explicitLabelsStream = _labelsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['name'] ?? data['label'] ?? 'Untitled').toString();
      }).toList();
    }).startWith([]);

    final noteLabelsStream = _notesCollection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final Set<String> allLabels = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic>? labels = data['labels'] as List<dynamic>?;
        if (labels != null) {
          for (var label in labels) {
            allLabels.add(label.toString());
          }
        }
      }
      return allLabels.toList();
    }).startWith([]);

    return Rx.combineLatest2<List<String>, List<String>, List<String>>(
      explicitLabelsStream,
      noteLabelsStream,
      (explicit, fromNotes) {
        final combined = <String>{...explicit, ...fromNotes}.toList();
        return combined..sort();
      },
    );
  }

  Future<void> addLabel(String name) async {
    // Check if label already exists
    final existing = await _labelsCollection.where('name', isEqualTo: name).get();
    if (existing.docs.isEmpty) {
      await _labelsCollection.add({'name': name});
    }
  }

  Future<void> deleteLabel(String name) async {
    // 1. Delete from explicit labels collection
    final docs = await _labelsCollection.where('name', isEqualTo: name).get();
    for (var doc in docs.docs) {
      await doc.reference.delete();
    }

    // 2. Remove from all notes that use this label
    final notesWithLabel = await _notesCollection.where('labels', arrayContains: name).get();
    for (var doc in notesWithLabel.docs) {
      await doc.reference.update({
        'labels': FieldValue.arrayRemove([name])
      });
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
