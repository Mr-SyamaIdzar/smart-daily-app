import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/auth/providers/auth_provider.dart';

import 'features/notes/providers/notes_provider.dart';
import 'features/weather/providers/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env file
  await dotenv.load(fileName: ".env");

  // Initialize dependency injection
  await ServiceLocator.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<NotesProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<WeatherProvider>()),
      ],
      child: const SmartDailyApp(),
    ),
  );
}
