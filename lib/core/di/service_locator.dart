import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

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

// Notes imports
import '../../data/datasources/local/notes_local_ds.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/notes/add_note_usecase.dart';
import '../../domain/usecases/notes/delete_note_usecase.dart';
import '../../domain/usecases/notes/get_notes_usecase.dart';
import '../../domain/usecases/notes/search_notes_usecase.dart';
import '../../domain/usecases/notes/update_note_usecase.dart';
import '../../features/notes/providers/notes_provider.dart';

// Weather imports
import '../../core/services/location_service.dart';
import '../../data/datasources/remote/weather_remote_ds.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/weather/get_weather_by_city_usecase.dart';
import '../../domain/usecases/weather/get_weather_by_location_usecase.dart';
import '../../features/weather/providers/weather_provider.dart';

// Currency imports
import 'package:dio/dio.dart';
import '../../data/datasources/remote/currency_api_service.dart';
import '../../data/repositories/currency_repository.dart';
import '../../features/tools/providers/currency_provider.dart';
import '../../features/tools/providers/time_converter_provider.dart';

// AI Chatbot imports
import '../../features/ai/gemini_service.dart';
import '../../features/ai/providers/chat_provider.dart';

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
    sl.registerLazySingleton<LocationService>(() => LocationService());

    // Registers http Client
    sl.registerLazySingleton<http.Client>(() => http.Client());
    sl.registerLazySingleton<Dio>(() => Dio());

    // === Data Sources ===
    sl.registerLazySingleton<DbHelper>(() => DbHelper.instance);

    sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSource(sl<DbHelper>()),
    );
    
    sl.registerLazySingleton<NotesLocalDataSource>(
      () => NotesLocalDataSourceImpl(sl<DbHelper>()),
    );

    sl.registerLazySingleton<WeatherRemoteDataSource>(
      () => WeatherRemoteDataSourceImpl(client: sl<http.Client>()),
    );

    sl.registerLazySingleton<CurrencyApiService>(
      () => CurrencyApiService(sl<Dio>()),
    );

    sl.registerLazySingleton<GeminiService>(
      () => GeminiService(sl<http.Client>()),
    );

    // === Repositories ===
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        localDataSource: sl<UserLocalDataSource>(),
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    );

    sl.registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(localDataSource: sl<NotesLocalDataSource>()),
    );

    sl.registerLazySingleton<WeatherRepository>(
      () => WeatherRepositoryImpl(remoteDataSource: sl<WeatherRemoteDataSource>()),
    );

    sl.registerLazySingleton<CurrencyRepository>(
      () => CurrencyRepository(sl<CurrencyApiService>()),
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

    sl.registerLazySingleton(() => GetNotesUseCase(sl<NotesRepository>()));
    sl.registerLazySingleton(() => SearchNotesUseCase(sl<NotesRepository>()));
    sl.registerLazySingleton(() => AddNoteUseCase(sl<NotesRepository>()));
    sl.registerLazySingleton(() => UpdateNoteUseCase(sl<NotesRepository>()));
    sl.registerLazySingleton(() => DeleteNoteUseCase(sl<NotesRepository>()));

    sl.registerLazySingleton(() => GetWeatherByCityUseCase(sl<WeatherRepository>()));
    sl.registerLazySingleton(() => GetWeatherByLocationUseCase(sl<WeatherRepository>()));

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

    // Register NotesProvider using factory so it gets a fresh state if needed, 
    // or lazySingleton if you want it to live forever.
    sl.registerLazySingleton(
      () => NotesProvider(
        authProvider: sl<AuthProvider>(),
        getNotesUseCase: sl<GetNotesUseCase>(),
        searchNotesUseCase: sl<SearchNotesUseCase>(),
        addNoteUseCase: sl<AddNoteUseCase>(),
        updateNoteUseCase: sl<UpdateNoteUseCase>(),
        deleteNoteUseCase: sl<DeleteNoteUseCase>(),
      ),
    );

    sl.registerLazySingleton(
      () => WeatherProvider(
        getWeatherByLocationUseCase: sl<GetWeatherByLocationUseCase>(),
        getWeatherByCityUseCase: sl<GetWeatherByCityUseCase>(),
        locationService: sl<LocationService>(),
      ),
    );

    sl.registerLazySingleton(
      () => CurrencyProvider(sl<CurrencyRepository>()),
    );

    sl.registerLazySingleton(
      () => TimeConverterProvider(),
    );

    sl.registerLazySingleton(
      () => ChatProvider(sl<GeminiService>()),
    );
  }
}

