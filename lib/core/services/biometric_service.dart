import 'package:local_auth/local_auth.dart';
import '../constants/app_strings.dart';

/// Service untuk menangani autentikasi biometrik (fingerprint / face ID).
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Cek apakah perangkat mendukung Face ID dan sudah terdaftar.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Ambil daftar biometrik yang tersedia.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Lakukan autentikasi biometrik.
  /// Returns [true] jika berhasil, [false] jika gagal/dibatalkan.
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: AppStrings.biometricReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Batalkan autentikasi yang sedang berjalan.
  Future<void> stopAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}
