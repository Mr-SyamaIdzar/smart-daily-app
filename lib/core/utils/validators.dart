/// Utility untuk validasi form input.
/// Setiap method mengembalikan String? — null = valid, String = pesan error.
abstract class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final baseError = password(value);
    if (baseError != null) return baseError;
    if (value != original) return 'Konfirmasi password tidak cocok';
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName wajib diisi';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama lengkap wajib diisi';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }
}
