import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:typed_data';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ── Channel IDs ──────────────────────────────────────────────────────────
  static const String _mainChannelId = 'main_channel';
  static const String _mainChannelName = 'Main Notifications';

  static const String _reminderChannelId = 'reminder_alarm_channel';
  static const String _reminderChannelName = 'Reminder Alarms';

  static const String _dailyChannelId = 'daily_reminder_channel';
  static const String _dailyChannelName = 'Daily Reminders';

  // ─────────────────────────────────────────────────────────────────────────

  /// Inisialisasi layanan notifikasi.
  Future<void> init() async {
    try {
      // 1. Inisialisasi Timezone
      tz.initializeTimeZones();
      final TimezoneInfo timezoneInfo =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      print('Timezone initialized: ${timezoneInfo.identifier}');

      // 2. Setup Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. Setup iOS
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 4. Inisialisasi Plugin
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print('Notification clicked: ${details.payload}');
        },
      );

      // 5. Request Permissions (Terutama untuk Android 13+)
      await _requestPermissions();

      print('Notification Service initialized successfully');
    } catch (e) {
      print('Error initializing Notification Service: $e');
    }
  }

  /// Request izin notifikasi untuk Android dan iOS.
  Future<void> _requestPermissions() async {
    // Untuk Android 13+
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      // Untuk Alarm Eksak
      await androidImplementation.requestExactAlarmsPermission();
    }

    // Untuk iOS
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ── Reminder Notification Details (dengan suara & getar) ─────────────────

  NotificationDetails _reminderNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: 'Channel untuk alarm pengingat dengan suara & getar',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
        playSound: true,
        // Menggunakan default sound sistem — tidak perlu file kustom
        sound: null,
        ticker: 'Reminder',
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(''),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ── PUBLIC API ────────────────────────────────────────────────────────────

  /// Menampilkan notifikasi instan (manual trigger).
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _mainChannelId,
      _mainChannelName,
      channelDescription: 'Channel untuk notifikasi utama aplikasi',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Menjadwalkan notifikasi pada tanggal & waktu tertentu (satu kali).
  ///
  /// - [id]       : ID unik notifikasi (gunakan reminder.id)
  /// - [dateTime] : Waktu tujuan (harus di masa depan)
  /// - [title]    : Judul notifikasi
  /// - [body]     : Isi notifikasi
  /// - [payload]  : Data opsional yang dikirim bersama notifikasi
  Future<void> scheduleNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(dateTime, tz.local);

    // Pastikan waktu belum lewat
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print('⚠️  scheduleNotification: waktu sudah lewat, notifikasi dilewati.');
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _reminderNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    print('✅ Notifikasi dijadwalkan [id=$id] pada $dateTime');
  }

  /// Membatalkan notifikasi berdasarkan ID.
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print('🗑️  Notifikasi [id=$id] dibatalkan.');
  }

  /// Menjadwalkan notifikasi harian pada waktu tertentu (berulang).
  Future<void> scheduleDailyNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          _dailyChannelName,
          channelDescription: 'Channel untuk pengingat harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Berulang harian
    );
  }

  /// Menghapus semua notifikasi.
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('🗑️  Semua notifikasi dibatalkan.');
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  /// Helper: waktu berikutnya (besok jika waktu sudah lewat).
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
