import 'package:get/get.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';

class NoteController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<Note> allNotes = <Note>[].obs;
  final RxList<Note> favoriteNotes = <Note>[].obs;
  final RxList<Note> archivedNotes = <Note>[].obs;
  final RxList<Note> trashNotes = <Note>[].obs;
  final RxList<String> labels = <String>[].obs;
  final RxString selectedLabel = ''.obs;

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

  List<Note> get filteredNotes {
    if (selectedLabel.isEmpty) {
      return allNotes;
    }
    return allNotes.where((note) => note.labels.contains(selectedLabel.value)).toList();
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

  // Archive Operations
  // Note: These are now superseded by the RxLists above, but keeping them as streams if needed
  Stream<List<Note>> get archivedNotesStream => _firestoreService.getNotes(isArchived: true, isDeleted: false);
  Stream<List<Note>> get trashNotesStream => _firestoreService.getNotes(isDeleted: true);
  Stream<List<Note>> get favoriteNotesStream => _firestoreService.getNotes(isFavorite: true, isDeleted: false);
  
  Stream<int> get noteCount => _firestoreService.getNoteCount();
}
