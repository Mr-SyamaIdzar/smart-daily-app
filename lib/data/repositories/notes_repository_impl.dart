import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/local/notes_local_ds.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl({required this.localDataSource});

  @override
  Future<NoteEntity> addNote(NoteEntity note) async {
    final model = NoteModel(
      id: note.id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
    final result = await localDataSource.addNote(model);
    return result; // NoteModel is a NoteEntity
  }

  @override
  Future<void> deleteNote(int id) async {
    await localDataSource.deleteNote(id);
  }

  @override
  Future<List<NoteEntity>> getNotes(int userId) async {
    // Inject dummy if empty (to satisfy user's request)
    await localDataSource.insertDummyDataIfNeeded(userId);
    
    final models = await localDataSource.getNotes(userId);
    return List<NoteEntity>.from(models);
  }

  @override
  Future<List<NoteEntity>> searchNotes(int userId, String query) async {
    final models = await localDataSource.searchNotes(userId, query);
    return List<NoteEntity>.from(models);
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    final model = NoteModel(
      id: note.id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
    await localDataSource.updateNote(model);
  }
}
