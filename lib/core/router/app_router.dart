import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/main/main_page.dart';
import '../../features/notes/note_form_page.dart';
import '../../domain/entities/note_entity.dart';
import '../../features/weather/weather_page.dart';
import '../../features/tools/currency_converter_page.dart';
import '../../features/tools/time_converter_page.dart';
import '../../features/ai/chatbot_page.dart';
import '../../features/tools/notification_test_page.dart';
import '../../features/tools/daily_focus_memory_match_page.dart';
import '../../features/profile/feedback_page.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter.
/// Fitur: route protection (redirect ke /login jika belum auth).
abstract class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  static final GlobalKey<NavigatorState> rootNavigatorKey = 
      GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: login,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == login ||
            state.matchedLocation == register;

        if (isLoggedIn && isAuthRoute) return home;
        if (!isLoggedIn && !isAuthRoute) return login;

        return null;
      },
      routes: [
        GoRoute(
          path: login,
          name: 'login',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoginPage(),
          ),
        ),
        GoRoute(
          path: register,
          name: 'register',
          pageBuilder: (context, state) => const MaterialPage(
            child: RegisterPage(),
          ),
        ),
        GoRoute(
          path: home,
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MainPage(),
          ),
        ),
        GoRoute(
          path: '/notes/form',
          name: 'note_form',
          pageBuilder: (context, state) {
            final noteToEdit = state.extra as NoteEntity?;
            return MaterialPage(
              child: NoteFormPage(noteToEdit: noteToEdit),
            );
          },
        ),
        GoRoute(
          path: '/tools/weather',
          name: 'tools_weather',
          pageBuilder: (context, state) => const MaterialPage(
            child: WeatherPage(),
          ),
        ),
        GoRoute(
          path: '/tools/currency',
          name: 'tools_currency',
          pageBuilder: (context, state) => const MaterialPage(
            child: CurrencyConverterPage(),
          ),
        ),
        GoRoute(
          path: '/tools/time',
          name: 'tools_time',
          pageBuilder: (context, state) => const MaterialPage(
            child: TimeConverterPage(),
          ),
        ),
        GoRoute(
          path: '/tools/chatbot',
          name: 'tools_chatbot',
          pageBuilder: (context, state) => const MaterialPage(
            child: ChatbotPage(),
          ),
        ),
        GoRoute(
          path: '/tools/notifications',
          name: 'tools_notifications',
          pageBuilder: (context, state) => const MaterialPage(
            child: NotificationTestPage(),
          ),
        ),
        GoRoute(
          path: '/tools/daily-focus',
          name: 'tools_daily_focus',
          pageBuilder: (context, state) => const MaterialPage(
            child: DailyFocusMemoryMatchPage(),
          ),
        ),
        GoRoute(
          path: '/profile/feedback',
          name: 'profile_feedback',
          pageBuilder: (context, state) => const MaterialPage(
            child: FeedbackPage(),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Halaman tidak ditemukan: ${state.error}'),
        ),
      ),
    );
  }
}
