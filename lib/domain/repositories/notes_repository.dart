import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes(int userId);
  Future<List<NoteEntity>> searchNotes(int userId, String query);
  Future<NoteEntity> addNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(int id);
}
