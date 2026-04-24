import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/utils/hash_helper.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/local/user_local_ds.dart';
import '../models/user_model.dart';

/// Implementasi AuthRepository.
/// Menggabungkan UserLocalDataSource (SQLite) + FlutterSecureStorage (sesi).
class AuthRepositoryImpl implements AuthRepository {
  final UserLocalDataSource _localDataSource;
  final FlutterSecureStorage _secureStorage;

  static const String _sessionUserIdKey = 'session_user_id';

  const AuthRepositoryImpl({
    required UserLocalDataSource localDataSource,
    required FlutterSecureStorage secureStorage,
  })  : _localDataSource = localDataSource,
        _secureStorage = secureStorage;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final userModel = await _localDataSource.getUserByEmail(email);

    if (userModel == null) {
      throw Exception('Email atau password salah.');
    }

    final isPasswordValid = HashHelper.verifyPassword(
      password,
      userModel.passwordHash,
    );

    if (!isPasswordValid) {
      throw Exception('Email atau password salah.');
    }

    return userModel.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final hashedPassword = HashHelper.hashPassword(password);

    final newUserModel = UserModel(
      fullName: fullName,
      email: email,
      passwordHash: hashedPassword,
      createdAt: DateTime.now().toIso8601String(),
    );

    final savedModel = await _localDataSource.insertUser(newUserModel);
    return savedModel.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    final userId = await _secureStorage.read(key: _sessionUserIdKey);
    return userId != null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userIdStr = await _secureStorage.read(key: _sessionUserIdKey);
    if (userIdStr == null) return null;

    final userId = int.tryParse(userIdStr);
    if (userId == null) return null;

    final userModel = await _localDataSource.getUserById(userId);
    return userModel?.toEntity();
  }

  @override
  Future<void> saveSession(UserEntity user) async {
    if (user.id == null) return;
    await _secureStorage.write(
      key: _sessionUserIdKey,
      value: user.id.toString(),
    );
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(key: _sessionUserIdKey);
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    return _localDataSource.emailExists(email);
  }

  @override
  Future<UserEntity?> getBiometricUserByEmail(String email) async {
    final enabledStr = await _secureStorage.read(key: 'bio_$email');
    if (enabledStr != 'true') return null;

    final userModel = await _localDataSource.getUserByEmail(email);
    return userModel?.toEntity();
  }

  @override
  Future<void> updateProfilePhoto(int userId, String photoPath) async {
    await _localDataSource.updateProfilePhoto(userId, photoPath);
  }
}
