import 'dart:math';

import 'package:http/http.dart' as http;

/// Chatbot gratis (offline).
///
/// NOTE:
/// - Nama class tetap `GeminiService` supaya integrasi DI yang sudah ada tidak
///   perlu diubah (service locator & provider).
/// - Implementasi ini TIDAK memakai API key / internet, jadi aman & gratis.
class GeminiService {
  GeminiService(this._client);

  // Disimpan agar tidak memutus dependency graph yang sudah ada.
  // ignore: unused_field
  final http.Client _client;

  final Random _rng = Random();

  Future<String> sendMessage(String text) async {
    final q = _normalize(text);
    if (q.isEmpty) return 'Coba tulis pertanyaanmu ya.';

    // Salam
    if (_matchAny(q, [
      RegExp(r'^(hi|hai|halo|hello)\b'),
      RegExp(r'\bass?alam(u|o)'),
      RegExp(r'\bpermisi\b'),
    ])) {
      return _pick([
        'Halo! Aku bisa bantu jelaskan fitur di aplikasi ini. Kamu mau tanya tentang apa?',
        'Hai! Mau dibantu pakai fitur apa? Mis. cuaca, catatan, tools, atau daily focus.',
      ]);
    }

    // Help / daftar fitur
    if (_matchAny(q, [
      RegExp(r'\b(help|bantuan|menu|fitur|apa (saja|aja) (fitur|menunya))\b'),
      RegExp(r'\bcara pakai\b'),
    ])) {
      return [
        'Aku bisa bantu fitur-fitur ini:',
        '1) Notes/Catatan: tambah, edit, hapus, cari catatan.',
        '2) Tools: Cuaca, Konversi Waktu, Konversi Mata Uang, Notifikasi.',
        '3) Daily Focus: mini game Memory Match untuk pemanasan fokus.',
        '',
        'Ketik misalnya: "cara pakai cuaca", "buka daily focus", atau "cara buat catatan".',
      ].join('\n');
    }

    // Daily Focus game
    if (_matchAny(q, [
      RegExp(r'\b(daily\s*focus|memory\s*match|game)\b'),
      RegExp(r'\bmain\b.*\b(game|daily)\b'),
      RegExp(r'\bbuka\b.*\b(daily|game|focus)\b'),
    ])) {
      return [
        'Daily Focus (Memory Match) itu game singkat 1–2 menit untuk warming up fokus.',
        'Cara main:',
        '- Tap 2 kartu untuk mencari pasangan yang sama.',
        '- Semakin sedikit moves & semakin cepat waktunya, semakin bagus.',
        '',
        'Buka dari: Tools → Daily Focus.',
      ].join('\n');
    }

    // Cuaca
    if (_matchAny(q, [
      RegExp(r'\bcuaca\b'),
      RegExp(r'\bweather\b'),
    ])) {
      return [
        'Fitur Cuaca bisa cek kondisi berdasarkan lokasi atau nama kota.',
        'Buka dari: Tools → Cuaca.',
        '',
        'Kalau lokasi tidak terdeteksi, pastikan izin lokasi (Location) aktif di perangkat.',
      ].join('\n');
    }

    // Konversi waktu
    if (_matchAny(q, [
      RegExp(r'\bkonversi\b.*\bwaktu\b'),
      RegExp(r'\bwaktu\b.*\bkonversi\b'),
      RegExp(r'\btime\s*converter\b'),
    ])) {
      return [
        'Konversi Waktu dipakai untuk mengubah format/zonawaktu (sesuai fitur yang tersedia di halaman).',
        'Buka dari: Tools → Konversi Waktu.',
      ].join('\n');
    }

    // Mata uang
    if (_matchAny(q, [
      RegExp(r'\b(mata\s*uang|kurs|currency)\b'),
      RegExp(r'\bkonversi\b.*\b(uang|kurs)\b'),
    ])) {
      return [
        'Konversi Mata Uang dipakai untuk menghitung nilai tukar.',
        'Buka dari: Tools → Mata Uang.',
        '',
        'Kalau hasil tidak muncul, biasanya karena koneksi atau API rate limit.',
      ].join('\n');
    }

    // Notifikasi
    if (_matchAny(q, [
      RegExp(r'\bnotifikasi\b'),
      RegExp(r'\bnotification\b'),
      RegExp(r'\bpengingat\b'),
    ])) {
      return [
        'Fitur Notifikasi dipakai untuk mencoba/mengetes notifikasi lokal.',
        'Buka dari: Tools → Notifikasi.',
        '',
        'Pastikan izin notifikasi aktif agar notifikasi muncul.',
      ].join('\n');
    }

    // Notes
    if (_matchAny(q, [
      RegExp(r'\b(catatan|notes?)\b'),
      RegExp(r'\btambah\b.*\bcatatan\b'),
      RegExp(r'\bcari\b.*\bcatatan\b'),
    ])) {
      return [
        'Untuk catatan:',
        '- Tambah: buka menu Notes lalu tekan tombol tambah.',
        '- Edit: buka catatan lalu pilih edit.',
        '- Cari: gunakan fitur pencarian di halaman Notes.',
      ].join('\n');
    }

    // Login / register
    if (_matchAny(q, [
      RegExp(r'\b(login|masuk|signin)\b'),
      RegExp(r'\b(register|daftar|signup)\b'),
      RegExp(r'\bbiometrik\b'),
      RegExp(r'\bfingerprint\b'),
    ])) {
      return [
        'Untuk autentikasi:',
        '- Kamu bisa login/daftar dari halaman awal.',
        '- Jika tersedia, kamu bisa gunakan biometrik (fingerprint) untuk login cepat.',
      ].join('\n');
    }

    // Fallback
    return _pick([
      'Aku bisa bantu jelasin fitur aplikasi. Kamu mau bahas: cuaca, notes, tools, notifikasi, atau daily focus?',
      'Biar aku tepat jawabnya, ini tentang fitur apa: catatan, cuaca, konversi, notifikasi, atau game Daily Focus?',
      'Aku belum paham maksudnya. Coba tulis contoh: "cara pakai cuaca" atau "buka daily focus".',
    ]);
  }

  String _normalize(String s) {
    var t = s.trim().toLowerCase();
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  bool _matchAny(String q, List<RegExp> patterns) {
    for (final p in patterns) {
      if (p.hasMatch(q)) return true;
    }
    return false;
  }

  String _pick(List<String> options) => options[_rng.nextInt(options.length)];
}

