/// String konstanta untuk menghindari typo dan memudahkan lokalisasi ke depan.
abstract class AppStrings {
  // === App ===
  static const String appName = 'Smart Daily Assistant';
  static const String appTagline = 'Your everyday companion';

  // === Auth ===
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Kata Sandi';
  static const String confirmPassword = 'Konfirmasi Kata Sandi';
  static const String fullName = 'Nama Lengkap';
  static const String forgotPassword = 'Lupa kata sandi?';
  static const String dontHaveAccount = 'Belum punya akun? ';
  static const String alreadyHaveAccount = 'Sudah punya akun? ';
  static const String loginWithBiometric = 'Masuk dengan Biometrik';
  static const String biometricReason = 'Verifikasi identitas Anda untuk masuk';
  static const String biometricNotAvailable = 'Biometrik tidak tersedia di perangkat ini';

  // === Validation Messages ===
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String emailInvalid = 'Format email tidak valid';
  static const String passwordMinLength = 'Password minimal 8 karakter';
  static const String passwordMismatch = 'Konfirmasi password tidak cocok';
  static const String loginFailed = 'Email atau password salah';
  static const String emailAlreadyExists = 'Email sudah terdaftar';
  static const String registerSuccess = 'Akun berhasil dibuat! Silakan masuk.';

  // === Navigation ===
  static const String navHome = 'Beranda';
  static const String navNotes = 'Catatan';
  static const String navTools = 'Tools';
  static const String navProfile = 'Profil';

  // === General ===
  static const String loading = 'Memuat...';
  static const String retry = 'Coba Lagi';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String search = 'Cari...';
}
