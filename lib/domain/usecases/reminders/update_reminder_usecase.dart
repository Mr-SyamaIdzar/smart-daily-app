import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';

class UpdateReminderUseCase {
  final ReminderRepository _repository;

  const UpdateReminderUseCase(this._repository);

  Future<void> call(ReminderEntity reminder) {
    return _repository.updateReminder(reminder);
  }
}
