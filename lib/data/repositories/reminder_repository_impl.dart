import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local/reminder_local_ds.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ReminderEntity>> getReminders(int userId) async {
    return localDataSource.getReminders(userId);
  }

  @override
  Future<ReminderEntity> addReminder(ReminderEntity reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    return localDataSource.addReminder(model);
  }

  @override
  Future<void> updateReminder(ReminderEntity reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    return localDataSource.updateReminder(model);
  }

  @override
  Future<void> deleteReminder(int id) async {
    return localDataSource.deleteReminder(id);
  }
}
