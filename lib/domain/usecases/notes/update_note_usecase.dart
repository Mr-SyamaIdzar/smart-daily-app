import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<void> call(NoteEntity note) {
    return repository.updateNote(note);
  }
}
