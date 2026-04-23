import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class SearchNotesUseCase {
  final NotesRepository repository;

  SearchNotesUseCase(this.repository);

  Future<List<NoteEntity>> call(int userId, String query) {
    return repository.searchNotes(userId, query);
  }
}
