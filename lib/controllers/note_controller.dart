import 'package:get/get.dart';
import '../models/note.dart';
import '../services/local_database_service.dart';
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
  final LocalDatabaseService _dbService = Get.find<LocalDatabaseService>();
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<Note> allNotes = <Note>[].obs;
  final RxList<Note> favoriteNotes = <Note>[].obs;
  final RxList<Note> archivedNotes = <Note>[].obs;
  final RxList<Note> trashNotes = <Note>[].obs;
  final RxList<String> labels = <String>[].obs;
  final RxString selectedLabel = ''.obs;
  final Rx<NoteFilter> currentFilter = NoteFilter.all.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotes();
    _listenToLabels();
    _listenToSpecialLists();
  }

  void _listenToNotes() {
    allNotes.bindStream(_dbService.getNotes(isArchived: false, isDeleted: false));
  }

  void _listenToLabels() {
    labels.bindStream(_dbService.getLabels());
  }

  void _listenToSpecialLists() {
    favoriteNotes.bindStream(_dbService.getNotes(isFavorite: true, isDeleted: false));
    archivedNotes.bindStream(_dbService.getNotes(isArchived: true, isDeleted: false));
    trashNotes.bindStream(_dbService.getNotes(isDeleted: true));
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
  Future<void> addNote(Note note) async {
    await _dbService.addNote(note);
    _firestoreService.syncNote(note); // Background sync
  }

  Future<void> updateNote(Note note) async {
    await _dbService.updateNote(note);
    _firestoreService.syncNote(note); // Background sync
  }

  Future<void> deleteNote(String id) async {
    await _dbService.moveToTrash(id);
    // Ideally update isDeleted in Firestore
    final note = allNotes.firstWhereOrNull((n) => n.id == id) ?? 
                 favoriteNotes.firstWhereOrNull((n) => n.id == id) ??
                 archivedNotes.firstWhereOrNull((n) => n.id == id);
    if (note != null) {
      _firestoreService.syncNote(note.copyWith(isDeleted: true));
    }
  }

  Future<void> restoreNote(String id) async {
    await _dbService.restoreFromTrash(id);
    final note = trashNotes.firstWhereOrNull((n) => n.id == id);
    if (note != null) {
      _firestoreService.syncNote(note.copyWith(isDeleted: false));
    }
  }

  Future<void> deleteNotePermanently(String id) async {
    await _dbService.deleteNote(id);
    _firestoreService.deleteNote(id); // Persistent deletion from cloud
  }

  Future<void> addLabel(String name) => _dbService.addLabel(name);
  Future<void> deleteLabel(String name) => _dbService.deleteLabel(name);

  Future<void> togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await _dbService.updateNote(updatedNote);
    _firestoreService.syncNote(updatedNote);
  }

  Future<void> toggleFavorite(Note note) async {
    final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
    await _dbService.updateNote(updatedNote);
    _firestoreService.syncNote(updatedNote);
  }

  Future<void> toggleArchive(Note note) async {
    final updatedNote = note.copyWith(isArchived: !note.isArchived);
    await _dbService.updateNote(updatedNote);
    _firestoreService.syncNote(updatedNote);
  }

  Future<void> moveToTrash(Note note) async {
    await _dbService.moveToTrash(note.id);
    _firestoreService.syncNote(note.copyWith(isDeleted: true));
  }

  Future<void> addLabelToNote(Note note, String label) async {
    if (!note.labels.contains(label)) {
      final updatedLabels = List<String>.from(note.labels)..add(label);
      final updatedNote = note.copyWith(labels: updatedLabels);
      await _dbService.updateNote(updatedNote);
      _firestoreService.syncNote(updatedNote);
    }
  }

  Future<void> removeLabelFromNote(Note note, String label) async {
    if (note.labels.contains(label)) {
      final updatedLabels = List<String>.from(note.labels)..remove(label);
      final updatedNote = note.copyWith(labels: updatedLabels);
      await _dbService.updateNote(updatedNote);
      _firestoreService.syncNote(updatedNote);
    }
  }

  // Archive Operations
  Stream<List<Note>> get archivedNotesStream => _dbService.getNotes(isArchived: true, isDeleted: false);
  Stream<List<Note>> get trashNotesStream => _dbService.getNotes(isDeleted: true);
  Stream<List<Note>> get favoriteNotesStream => _dbService.getNotes(isFavorite: true, isDeleted: false);
  
  Future<void> fetchNotes() async {
    isLoading.value = true;
    try {
      // Small delay to show off the beautiful shimmers
      await Future.delayed(const Duration(milliseconds: 800));
      _listenToNotes();
      _listenToLabels();
      _listenToSpecialLists();
    } finally {
      isLoading.value = false;
    }
  }

  Stream<int> get noteCount => _dbService.getNoteCount();
}
