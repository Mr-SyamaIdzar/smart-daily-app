import 'package:flutter/foundation.dart';
import '../../../domain/entities/note_entity.dart';
import '../../../domain/usecases/notes/add_note_usecase.dart';
import '../../../domain/usecases/notes/delete_note_usecase.dart';
import '../../../domain/usecases/notes/get_notes_usecase.dart';
import '../../../domain/usecases/notes/search_notes_usecase.dart';
import '../../../domain/usecases/notes/update_note_usecase.dart';
import '../../auth/providers/auth_provider.dart';

class NotesProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final GetNotesUseCase getNotesUseCase;
  final SearchNotesUseCase searchNotesUseCase;
  final AddNoteUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NotesProvider({
    required this.authProvider,
    required this.getNotesUseCase,
    required this.searchNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) {
    // Automatically fetch notes when auth state changes to logged in
    authProvider.addListener(_onAuthStateChanged);
  }

  List<NoteEntity> _notes = [];
  List<NoteEntity> get notes => _notes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _onAuthStateChanged() {
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      fetchNotes();
    } else {
      _notes = [];
      notifyListeners();
    }
  }

  Future<void> fetchNotes() async {
    final user = authProvider.currentUser;
    if (user == null || user.id == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await getNotesUseCase(user.id!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchNotes(String query) async {
    final user = authProvider.currentUser;
    if (user == null || user.id == null) return;

    if (query.trim().isEmpty) {
      return fetchNotes(); // Re-fetch all if query is empty
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await searchNotesUseCase(user.id!, query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addNote(String title, String content) async {
    final user = authProvider.currentUser;
    if (user == null || user.id == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final newNote = NoteEntity(
        userId: user.id!,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      final addedNote = await addNoteUseCase(newNote);
      _notes.insert(0, addedNote); // Insert at the top
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNote(int id, String title, String content, DateTime createdAt) async {
    final user = authProvider.currentUser;
    if (user == null || user.id == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedNote = NoteEntity(
        id: id,
        userId: user.id!,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: DateTime.now(), // Update timestamp
      );

      await updateNoteUseCase(updatedNote);
      
      // Update local state and move to top
      _notes.removeWhere((note) => note.id == id);
      _notes.insert(0, updatedNote);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNote(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await deleteNoteUseCase(id);
      _notes.removeWhere((note) => note.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
