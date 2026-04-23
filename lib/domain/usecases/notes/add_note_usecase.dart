import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class AddNoteUseCase {
  final NotesRepository repository;

  AddNoteUseCase(this.repository);

  Future<NoteEntity> call(NoteEntity note) {
    return repository.addNote(note);
  }
}
