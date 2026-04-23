import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/auth/providers/auth_provider.dart';

import 'features/notes/providers/notes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await ServiceLocator.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.sl<NotesProvider>()),
      ],
      child: const SmartDailyApp(),
    ),
  );
}
