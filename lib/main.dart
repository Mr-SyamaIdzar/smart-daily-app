import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/auth/providers/auth_provider.dart';

import 'features/notes/providers/notes_provider.dart';
import 'features/weather/providers/weather_provider.dart';
import 'features/tools/providers/currency_provider.dart';
import 'features/tools/providers/time_converter_provider.dart';
import 'features/ai/providers/chat_provider.dart';
import 'core/services/notification_service.dart';
import 'features/reminders/providers/reminder_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale data untuk intl (format tanggal Bahasa Indonesia)
  await initializeDateFormatting('id_ID', null);

  // Load env file
  await dotenv.load(fileName: ".env");

  // Initialize dependency injection
  await ServiceLocator.init();
  
  // Initialize Notification Service
  await ServiceLocator.sl<NotificationService>().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<NotesProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<WeatherProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<CurrencyProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<TimeConverterProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<ReminderProvider>()),
      ],
      child: const SmartDailyApp(),
    ),
  );
}
