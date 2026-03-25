import 'package:get/get.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';

enum NoteFilter {
  all,
  hasSignature,
  hasImage,
  dateNewest,
  dateOldest,
  byDate,
}

class NoteController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<Note> allNotes = <Note>[].obs;
  final RxList<Note> favoriteNotes = <Note>[].obs;
  final RxList<Note> archivedNotes = <Note>[].obs;
  final RxList<Note> trashNotes = <Note>[].obs;
  final RxList<String> labels = <String>[].obs;
  final RxString selectedLabel = ''.obs;
  final Rx<NoteFilter> currentFilter = NoteFilter.all.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _listenToNotes();
    _listenToLabels();
    _listenToSpecialLists();
  }

  void _listenToNotes() {
    allNotes.bindStream(_firestoreService.getNotes(isArchived: false, isDeleted: false));
  }

  void _listenToLabels() {
    labels.bindStream(_firestoreService.getLabels());
  }

  void _listenToSpecialLists() {
    favoriteNotes.bindStream(_firestoreService.getNotes(isFavorite: true, isDeleted: false));
    archivedNotes.bindStream(_firestoreService.getNotes(isArchived: true, isDeleted: false));
    trashNotes.bindStream(_firestoreService.getNotes(isDeleted: true));
  }

  List<Note> get filteredNotes => _applyFilter(allNotes.where((note) {
    if (selectedLabel.isEmpty) return true;
    return note.labels.contains(selectedLabel.value);
  }).toList());

  List<Note> get filteredFavoriteNotes => _applyFilter(favoriteNotes);
  List<Note> get filteredArchivedNotes => _applyFilter(archivedNotes);
  List<Note> get filteredTrashNotes => _applyFilter(trashNotes);

  List<Note> _applyFilter(List<Note> notesList) {
    List<Note> notes = List<Note>.from(notesList);

    // Apply Filter
    switch (currentFilter.value) {
      case NoteFilter.hasSignature:
        notes = notes.where((n) => n.signatureUrl != null && n.signatureUrl!.isNotEmpty).toList();
        break;
      case NoteFilter.hasImage:
        notes = notes.where((n) => n.imageUrl != null && n.imageUrl!.isNotEmpty).toList();
        break;
      case NoteFilter.dateNewest:
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteFilter.dateOldest:
        notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteFilter.byDate:
        if (selectedDate.value != null) {
          notes = notes.where((n) {
            final date = n.createdAt;
            final selected = selectedDate.value!;
            return date.year == selected.year && 
                   date.month == selected.month && 
                   date.day == selected.day;
          }).toList();
        }
        break;
      case NoteFilter.all:
        break;
    }

    return notes;
  }

  void setFilter(NoteFilter filter, {DateTime? date}) {
    currentFilter.value = filter;
    if (filter == NoteFilter.byDate && date != null) {
      selectedDate.value = date;
    } else if (filter != NoteFilter.byDate) {
      selectedDate.value = null;
    }
  }

  void setSelectedLabel(String? label) {
    selectedLabel.value = label ?? '';
  }

  // CRUD Operations
  Future<void> addNote(Note note) => _firestoreService.addNote(note);
  Future<void> updateNote(Note note) => _firestoreService.updateNote(note);
  Future<void> deleteNote(String id) => _firestoreService.moveToTrash(id);
  Future<void> restoreNote(String id) => _firestoreService.restoreFromTrash(id);
  Future<void> deleteNotePermanently(String id) => _firestoreService.deleteNote(id);
  Future<void> addLabel(String name) => _firestoreService.addLabel(name);
  Future<void> deleteLabel(String name) => _firestoreService.deleteLabel(name);

  Future<void> togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await _firestoreService.updateNote(updatedNote);
  }

  Future<void> toggleFavorite(Note note) async {
    final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
    await _firestoreService.updateNote(updatedNote);
  }

  Future<void> toggleArchive(Note note) async {
    final updatedNote = note.copyWith(isArchived: !note.isArchived);
    await _firestoreService.updateNote(updatedNote);
  }

  Future<void> moveToTrash(Note note) async {
    await _firestoreService.moveToTrash(note.id);
  }

  Future<void> addLabelToNote(Note note, String label) async {
    if (!note.labels.contains(label)) {
      final updatedLabels = List<String>.from(note.labels)..add(label);
      final updatedNote = note.copyWith(labels: updatedLabels);
      await _firestoreService.updateNote(updatedNote);
    }
  }

  Future<void> removeLabelFromNote(Note note, String label) async {
    if (note.labels.contains(label)) {
      final updatedLabels = List<String>.from(note.labels)..remove(label);
      final updatedNote = note.copyWith(labels: updatedLabels);
      await _firestoreService.updateNote(updatedNote);
    }
  }

  // Archive Operations
  // Note: These are now superseded by the RxLists above, but keeping them as streams if needed
  Stream<List<Note>> get archivedNotesStream => _firestoreService.getNotes(isArchived: true, isDeleted: false);
  Stream<List<Note>> get trashNotesStream => _firestoreService.getNotes(isDeleted: true);
  Stream<List<Note>> get favoriteNotesStream => _firestoreService.getNotes(isFavorite: true, isDeleted: false);
  
  Stream<int> get noteCount => _firestoreService.getNoteCount();
}
