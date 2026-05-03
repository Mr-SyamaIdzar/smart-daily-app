import '../../repositories/reminder_repository.dart';

class DeleteReminderUseCase {
  final ReminderRepository _repository;

  const DeleteReminderUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteReminder(id);
  }
}
