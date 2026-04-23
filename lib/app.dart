import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';

/// Root widget aplikasi.
/// MaterialApp dikonfigurasi di sini — theme, router, dan title.
class SmartDailyApp extends StatelessWidget {
  const SmartDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'Smart Daily Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(authProvider),
    );
  }
}
