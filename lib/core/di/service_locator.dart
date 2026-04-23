import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/biometric_service.dart';
import '../../data/datasources/local/db_helper.dart';
import '../../data/datasources/local/user_local_ds.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/biometric_login_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Service locator menggunakan GetIt.
/// Semua dependency diregistrasi di sini — satu titik kontrol untuk DI.
///
/// Cara pakai: `ServiceLocator.sl<AuthProvider>()`
abstract class ServiceLocator {
  static final GetIt sl = GetIt.instance;

  static Future<void> init() async {
    // === External Services ===
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    );

    sl.registerLazySingleton<BiometricService>(() => BiometricService());

    // === Data Sources ===
    sl.registerLazySingleton<DbHelper>(() => DbHelper.instance);

    sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSource(sl<DbHelper>()),
    );

    // === Repositories ===
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        localDataSource: sl<UserLocalDataSource>(),
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    );

    // === Use Cases ===
    sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(
      () => BiometricLoginUseCase(
        sl<AuthRepository>(),
        sl<BiometricService>(),
      ),
    );

    // === Providers ===
    sl.registerFactory(
      () => AuthProvider(
        loginUseCase: sl<LoginUseCase>(),
        registerUseCase: sl<RegisterUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        biometricLoginUseCase: sl<BiometricLoginUseCase>(),
        authRepository: sl<AuthRepository>(),
        biometricService: sl<BiometricService>(),
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    );
  }
}
