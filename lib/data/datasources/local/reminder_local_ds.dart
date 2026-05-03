import '../../models/reminder_model.dart';
import 'db_helper.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders(int userId);
  Future<ReminderModel> addReminder(ReminderModel reminder);
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(int id);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final DbHelper dbHelper;

  ReminderLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<ReminderModel>> getReminders(int userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbHelper.tableReminders,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'datetime ASC',
    );
    return maps.map((e) => ReminderModel.fromMap(e)).toList();
  }

  @override
  Future<ReminderModel> addReminder(ReminderModel reminder) async {
    final db = await dbHelper.database;
    final map = reminder.toMap()..remove('id');
    final id = await db.insert(DbHelper.tableReminders, map);
    return ReminderModel(
      id: id,
      userId: reminder.userId,
      title: reminder.title,
      description: reminder.description,
      dateTime: reminder.dateTime,
      isActive: reminder.isActive,
    );
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await dbHelper.database;
    await db.update(
      DbHelper.tableReminders,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  @override
  Future<void> deleteReminder(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      DbHelper.tableReminders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
