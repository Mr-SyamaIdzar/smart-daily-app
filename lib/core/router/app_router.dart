import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/main/main_page.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter.
/// Fitur: route protection (redirect ke /login jika belum auth).
abstract class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
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
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Halaman tidak ditemukan: ${state.error}'),
        ),
      ),
    );
  }
}
