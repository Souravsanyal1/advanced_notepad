import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import 'package:rxdart/rxdart.dart';

class LocalDatabaseService {
  static const String notesBoxName = 'notes';
  static const String labelsBoxName = 'labels';

  late Box<Note> _notesBox;
  late Box<String> _labelsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    _notesBox = await Hive.openBox<Note>(notesBoxName);
    _labelsBox = await Hive.openBox<String>(labelsBoxName);

    // Initial labels if empty
    if (_labelsBox.isEmpty) {
      await _labelsBox.addAll(['Personal', 'Work', 'Health', 'Finance']);
    }
  }

  Stream<List<Note>> getNotes({String? label, bool? isArchived, bool? isDeleted, bool? isFavorite}) {
    return _notesBox.watch().map((_) => _getFilteredNotes(label, isArchived, isDeleted, isFavorite))
        .startWith(_getFilteredNotes(label, isArchived, isDeleted, isFavorite));
  }

  List<Note> _getFilteredNotes(String? label, bool? isArchived, bool? isDeleted, bool? isFavorite) {
    var notes = _notesBox.values.toList();
    
    // Sort by updated at descending
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (label != null) {
      notes = notes.where((n) => n.labels.contains(label)).toList();
    }
    if (isArchived != null) {
      notes = notes.where((n) => n.isArchived == isArchived).toList();
    }
    if (isDeleted != null) {
      notes = notes.where((n) => n.isDeleted == isDeleted).toList();
    }
    if (isFavorite != null) {
      notes = notes.where((n) => n.isFavorite == isFavorite).toList();
    }

    return notes;
  }

  Stream<List<String>> getLabels() {
    // Explicit labels + labels extracted from notes
    return Rx.combineLatest2<BoxEvent, BoxEvent, List<String>>(
      _labelsBox.watch().startWith(BoxEvent(null, null, false)),
      _notesBox.watch().startWith(BoxEvent(null, null, false)),
      (labelsEvent, notesEvent) {
        final explicit = _labelsBox.values.toList();
        final fromNotes = _notesBox.values.where((n) => !n.isDeleted).expand((n) => n.labels).toSet();
        return <String>{...explicit, ...fromNotes}.toList()..sort();
      },
    );
  }

  Future<void> addNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> moveToTrash(String id) async {
    final note = _notesBox.get(id);
    if (note != null) {
      final updated = note.copyWith(isDeleted: true, isPinned: false);
      await _notesBox.put(id, updated);
    }
  }

  Future<void> restoreFromTrash(String id) async {
    final note = _notesBox.get(id);
    if (note != null) {
      final updated = note.copyWith(isDeleted: false);
      await _notesBox.put(id, updated);
    }
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<void> addLabel(String name) async {
    if (!_labelsBox.values.contains(name)) {
      await _labelsBox.add(name);
    }
  }

  Future<void> deleteLabel(String name) async {
    // 1. Delete from explicit labels
    final key = _labelsBox.keys.firstWhere((k) => _labelsBox.get(k) == name, orElse: () => null);
    if (key != null) {
      await _labelsBox.delete(key);
    }

    // 2. Remove from all notes
    final notesWithLabel = _notesBox.values.where((n) => n.labels.contains(name)).toList();
    for (var note in notesWithLabel) {
      final updatedLabels = List<String>.from(note.labels)..remove(name);
      await _notesBox.put(note.id, note.copyWith(labels: updatedLabels));
    }
  }

  Stream<int> getNoteCount() {
    return _notesBox.watch().map((_) => _notesBox.values.where((n) => !n.isDeleted).length)
        .startWith(_notesBox.values.where((n) => !n.isDeleted).length);
  }
}
