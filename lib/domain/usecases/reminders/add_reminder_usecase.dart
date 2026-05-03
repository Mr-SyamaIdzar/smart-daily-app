import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';

class AddReminderUseCase {
  final ReminderRepository _repository;

  const AddReminderUseCase(this._repository);

  Future<ReminderEntity> call(ReminderEntity reminder) {
    return _repository.addReminder(reminder);
  }
}
