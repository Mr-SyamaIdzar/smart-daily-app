import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper untuk hashing password menggunakan SHA-256.
///
/// Penggunaan:
/// ```dart
/// final hashed = HashHelper.hashPassword('mypassword123');
/// final isValid = HashHelper.verifyPassword('mypassword123', hashed);
/// ```
abstract class HashHelper {
  /// Hash password dengan SHA-256.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi password dengan hash yang tersimpan.
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    return hashPassword(plainPassword) == hashedPassword;
  }
}
