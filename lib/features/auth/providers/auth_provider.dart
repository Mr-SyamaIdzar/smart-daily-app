import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/biometric_service.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/biometric_login_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';

/// Status state untuk auth flow.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider untuk Auth — mengelola state login, register, dan biometrik.
/// Mengimplementasikan [ChangeNotifier] agar GoRouter bisa listen perubahan.
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final BiometricLoginUseCase _biometricLoginUseCase;
  final AuthRepository _authRepository;
  final BiometricService _biometricService;
  final FlutterSecureStorage _secureStorage;

  String _getBioKey(String email) => 'bio_$email';

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required BiometricLoginUseCase biometricLoginUseCase,
    required AuthRepository authRepository,
    required BiometricService biometricService,
    required FlutterSecureStorage secureStorage,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _biometricLoginUseCase = biometricLoginUseCase,
        _authRepository = authRepository,
        _biometricService = biometricService,
        _secureStorage = secureStorage {
    _checkSession();
  }

  // === State ===
  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;
  bool _isBiometricAvailable = false;
  /// True jika user sudah mengaktifkan biometrik (opt-in).
  bool _isBiometricEnabled = false;

  // === Getters ===
  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isBiometricAvailable => _isBiometricAvailable;
  /// True jika perangkat support biometrik DAN user sudah mengaktifkannya.
  bool get isBiometricEnabled => _isBiometricEnabled;
  /// True jika biometrik bisa digunakan untuk login (ada sesi + sudah diaktifkan).
  bool get canLoginWithBiometric => _isBiometricAvailable && _isBiometricEnabled;

  // === Private Helpers ===
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setAuthenticated(UserEntity user) {
    _status = AuthStatus.authenticated;
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  // === Public Methods ===

  /// Cek sesi saat app pertama dibuka.
  Future<void> _checkSession() async {
    try {
      // Cek biometrik dan status login
      final results = await Future.wait([
        _biometricService.isAvailable().catchError((_) => false),
        _authRepository.isLoggedIn().catchError((_) => false),
      ]);

      _isBiometricAvailable = results[0] as bool;
      final isLoggedIn = results[1] as bool;

      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          _isBiometricEnabled = (await _secureStorage.read(key: _getBioKey(user.email))) == 'true';
          _setAuthenticated(user);
          return; // notifyListeners sudah dipanggil di _setAuthenticated
        }
      }
    } catch (e) {
      // Ignore error & proceed as unauthenticated 
      _isBiometricAvailable = false;
      _isBiometricEnabled = false;
    }

    _setUnauthenticated();
  }

  /// Login dengan email & password.
  Future<void> login({required String email, required String password}) async {
    try {
      _setLoading();
      final user = await _loginUseCase(email: email, password: password);
      _setAuthenticated(user);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Registrasi user baru.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      await _registerUseCase(
        fullName: fullName,
        email: email,
        password: password,
      );
      _setUnauthenticated();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  /// Cek apakah suatu email punya biometrik aktif.
  Future<bool> hasBiometricForEmail(String email) async {
    if (email.isEmpty) return false;
    final val = await _secureStorage.read(key: _getBioKey(email));
    return val == 'true';
  }

  /// Login menggunakan biometrik.
  Future<void> loginWithBiometric(String email) async {
    try {
      _setLoading();
      final user = await _biometricLoginUseCase(email);
      _setAuthenticated(user);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Aktifkan biometrik untuk login selanjutnya.
  /// Harus dipanggil saat user sudah login (ada sesi aktif).
  Future<bool> enableBiometric() async {
    try {
      if (!_isBiometricAvailable) {
        throw Exception('Perangkat tidak mendukung biometrik.');
      }
      // Minta konfirmasi biometrik sebelum mengaktifkan
      final authenticated = await _biometricService.authenticate();
      if (!authenticated) return false;

      if (_currentUser == null) throw Exception('Tidak ada sesi tersimpan.');
      await _secureStorage.write(key: _getBioKey(_currentUser!.email), value: 'true');
      _isBiometricEnabled = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  /// Nonaktifkan biometrik.
  Future<void> disableBiometric() async {
    if (_currentUser != null) {
      await _secureStorage.delete(key: _getBioKey(_currentUser!.email));
    }
    _isBiometricEnabled = false;
    notifyListeners();
  }

  /// Logout — hapus sesi dan reset state.
  Future<void> logout() async {
    await _logoutUseCase();
    _setUnauthenticated();
  }

  /// Update foto profil user.
  Future<void> updatePhoto(String path) async {
    if (_currentUser == null || _currentUser!.id == null) return;
    
    try {
      await _authRepository.updateProfilePhoto(_currentUser!.id!, path);
      _currentUser = _currentUser!.copyWith(photoPath: path);
      notifyListeners();
    } catch (e) {
      _setError('Gagal memperbarui foto profil: $e');
    }
  }

  /// Update nama lengkap (username) user.
  Future<bool> updateUsername(String newName) async {
    if (_currentUser == null || _currentUser!.id == null) return false;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;

    try {
      await _authRepository.updateUsername(_currentUser!.id!, trimmed);
      _currentUser = _currentUser!.copyWith(fullName: trimmed);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal memperbarui nama: $e');
      return false;
    }
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
