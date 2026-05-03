import 'package:flutter/foundation.dart';

import '../../../core/services/notification_service.dart';
import '../../../domain/entities/reminder_entity.dart';
import '../../../domain/usecases/reminders/add_reminder_usecase.dart';
import '../../../domain/usecases/reminders/delete_reminder_usecase.dart';
import '../../../domain/usecases/reminders/get_reminders_usecase.dart';
import '../../../domain/usecases/reminders/update_reminder_usecase.dart';

enum ReminderStatus { initial, loading, loaded, error }

class ReminderProvider extends ChangeNotifier {
  final GetRemindersUseCase _getRemindersUseCase;
  final AddReminderUseCase _addReminderUseCase;
  final UpdateReminderUseCase _updateReminderUseCase;
  final DeleteReminderUseCase _deleteReminderUseCase;
  final NotificationService _notificationService;

  ReminderProvider({
    required GetRemindersUseCase getRemindersUseCase,
    required AddReminderUseCase addReminderUseCase,
    required UpdateReminderUseCase updateReminderUseCase,
    required DeleteReminderUseCase deleteReminderUseCase,
    required NotificationService notificationService,
  })  : _getRemindersUseCase = getRemindersUseCase,
        _addReminderUseCase = addReminderUseCase,
        _updateReminderUseCase = updateReminderUseCase,
        _deleteReminderUseCase = deleteReminderUseCase,
        _notificationService = notificationService;

  // ── State ─────────────────────────────────────────────────────────────────

  List<ReminderEntity> _reminders = [];
  ReminderStatus _status = ReminderStatus.initial;
  String _errorMessage = '';

  // ── Getters ───────────────────────────────────────────────────────────────

  List<ReminderEntity> get reminders => List.unmodifiable(_reminders);
  ReminderStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == ReminderStatus.loading;

  // ── Upcoming & Past ───────────────────────────────────────────────────────

  /// Reminder yang belum lewat waktunya (tampil di bagian atas).
  List<ReminderEntity> get upcomingReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => r.dateTime.isAfter(now) && r.isActive)
        .toList();
  }

  /// Reminder yang sudah lewat.
  List<ReminderEntity> get pastReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => r.dateTime.isBefore(now) || !r.isActive)
        .toList();
  }

  // ── Methods ───────────────────────────────────────────────────────────────

  /// Muat semua reminder milik user dari database.
  Future<void> loadReminders(int userId) async {
    _status = ReminderStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _reminders = await _getRemindersUseCase(userId);
      _status = ReminderStatus.loaded;
    } catch (e) {
      _status = ReminderStatus.error;
      _errorMessage = 'Gagal memuat reminder: $e';
      debugPrint('ReminderProvider.loadReminders error: $e');
    }

    notifyListeners();
  }

  /// Tambah reminder baru → simpan ke DB → schedule notifikasi.
  Future<bool> addReminder({
    required int userId,
    required String title,
    required String description,
    required DateTime dateTime,
  }) async {
    try {
      final newReminder = ReminderEntity(
        userId: userId,
        title: title,
        description: description,
        dateTime: dateTime,
        isActive: true,
      );

      final saved = await _addReminderUseCase(newReminder);

      // Schedule notifikasi dengan ID = reminder.id
      if (saved.id != null) {
        await _notificationService.scheduleNotification(
          id: saved.id!,
          dateTime: saved.dateTime,
          title: '🔔 ${saved.title}',
          body: saved.description,
          payload: 'reminder_${saved.id}',
        );
      }

      _reminders.add(saved);
      // Urutkan kembali berdasarkan datetime ASC
      _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah reminder: $e';
      debugPrint('ReminderProvider.addReminder error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Hapus reminder → batalkan notifikasi → hapus dari DB.
  Future<bool> deleteReminder(int id) async {
    try {
      // Cancel notifikasi terlebih dahulu
      await _notificationService.cancelNotification(id);

      // Hapus dari database
      await _deleteReminderUseCase(id);

      // Update local state
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus reminder: $e';
      debugPrint('ReminderProvider.deleteReminder error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update reminder yang sudah ada → reschedule notifikasi.
  Future<bool> updateReminder(ReminderEntity reminder) async {
    try {
      // Batalkan notifikasi lama
      if (reminder.id != null) {
        await _notificationService.cancelNotification(reminder.id!);
      }

      await _updateReminderUseCase(reminder);

      // Schedule notifikasi baru jika masih aktif dan belum lewat
      if (reminder.id != null &&
          reminder.isActive &&
          reminder.dateTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: reminder.id!,
          dateTime: reminder.dateTime,
          title: '🔔 ${reminder.title}',
          body: reminder.description,
          payload: 'reminder_${reminder.id}',
        );
      }

      // Update local state
      final idx = _reminders.indexWhere((r) => r.id == reminder.id);
      if (idx != -1) {
        _reminders[idx] = reminder;
        _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate reminder: $e';
      debugPrint('ReminderProvider.updateReminder error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Reschedule semua notifikasi aktif (dipanggil saat app dibuka ulang).
  Future<void> rescheduleActiveNotifications() async {
    final now = DateTime.now();
    for (final reminder in _reminders) {
      if (reminder.isActive &&
          reminder.dateTime.isAfter(now) &&
          reminder.id != null) {
        await _notificationService.scheduleNotification(
          id: reminder.id!,
          dateTime: reminder.dateTime,
          title: '🔔 ${reminder.title}',
          body: reminder.description,
          payload: 'reminder_${reminder.id}',
        );
      }
    }
    debugPrint(
        'ReminderProvider: reschedule selesai untuk ${upcomingReminders.length} reminder aktif.');
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
