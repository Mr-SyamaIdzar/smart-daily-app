import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/services/biometric_service.dart';

/// Use case untuk biometric login.
/// Flow: ambil user biometrik terakhir → trigger biometrik → pulihkan sesi → return UserEntity
class BiometricLoginUseCase {
  final AuthRepository _repository;
  final BiometricService _biometricService;

  const BiometricLoginUseCase(this._repository, this._biometricService);

  Future<UserEntity> call(String email) async {
    final user = await _repository.getBiometricUserByEmail(email);
    if (user == null) {
      throw Exception('Sidik jari belum diaktifkan untuk email ini.');
    }

    final available = await _biometricService.isAvailable();
    if (!available) {
      throw Exception('Biometrik tidak tersedia di perangkat ini.');
    }

    final authenticated = await _biometricService.authenticate();
    if (!authenticated) {
      throw Exception('Autentikasi biometrik gagal atau dibatalkan.');
    }

    // Berhasil, pulihkan sesi (login ulang)
    await _repository.saveSession(user);

    return user;
  }
}
