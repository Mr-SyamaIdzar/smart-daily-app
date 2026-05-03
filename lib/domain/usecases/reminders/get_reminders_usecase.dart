import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';

class GetRemindersUseCase {
  final ReminderRepository _repository;

  const GetRemindersUseCase(this._repository);

  Future<List<ReminderEntity>> call(int userId) {
    return _repository.getReminders(userId);
  }
}
