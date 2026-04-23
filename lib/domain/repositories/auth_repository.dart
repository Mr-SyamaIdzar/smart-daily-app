import '../entities/user_entity.dart';

/// Interface (abstract) untuk auth repository.
/// Domain layer mendefinisikan kontrak ini — data layer mengimplementasikannya.
abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<bool> isLoggedIn();

  Future<UserEntity?> getCurrentUser();

  Future<void> saveSession(UserEntity user);

  Future<void> clearSession();

  Future<bool> isEmailRegistered(String email);

  /// Mengambil data user untuk login biometrik berdasar email
  Future<UserEntity?> getBiometricUserByEmail(String email);
}
