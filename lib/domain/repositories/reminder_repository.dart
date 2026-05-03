import '../entities/reminder_entity.dart';

/// Contract/interface untuk operasi data Reminder.
/// Implementasi ada di data layer (ReminderRepositoryImpl).
abstract class ReminderRepository {
  /// Ambil semua reminder milik user tertentu (urut datetime ASC).
  Future<List<ReminderEntity>> getReminders(int userId);

  /// Tambah reminder baru, kembalikan entity dengan ID yang di-generate.
  Future<ReminderEntity> addReminder(ReminderEntity reminder);

  /// Update reminder yang sudah ada.
  Future<void> updateReminder(ReminderEntity reminder);

  /// Hapus reminder berdasarkan ID.
  Future<void> deleteReminder(int id);
}
