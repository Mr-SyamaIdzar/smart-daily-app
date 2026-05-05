# Dokumentasi & Analisis Proyek: Smart Daily Assistant App

Proyek ini adalah aplikasi Flutter bernama **Smart Daily Assistant App** (diinisialisasi dengan nama `tugas_akhir_app`). Aplikasi ini dirancang untuk membantu produktivitas harian pengguna dengan menyediakan berbagai fitur cerdas seperti manajemen catatan, pengingat, asisten AI, informasi cuaca, dan berbagai utilitas lainnya.

## 1. Arsitektur Proyek (Clean Architecture)

Aplikasi ini mengadopsi pola **Clean Architecture** yang memisahkan kode berdasarkan tanggung jawabnya. Hal ini membuat aplikasi lebih mudah di-maintain, di-test, dan diskalakan.

Struktur folder utama di `lib/`:
*   **`core/`**: Berisi fondasi aplikasi yang dapat digunakan di seluruh bagian fitur.
    *   `di/`: Dependency Injection menggunakan package `get_it`.
    *   `router/`: Manajemen rute/navigasi menggunakan `go_router`.
    *   `services/`: Layanan eksternal seperti `notification_service.dart`.
    *   `theme/`: Konfigurasi tema global dan warna (AppTheme).
    *   `utils/`: Fungsi utilitas bantuan (seperti `shake_detector_wrapper.dart`).
*   **`domain/`**: Lapisan bisnis logika (Business Rule). Lapisan ini independen dari framework UI.
    *   `entities/`: Model data murni (contoh: `NoteEntity`).
    *   `repositories/`: Abstract class (interface) yang mendefinisikan operasi apa saja yang bisa dilakukan terhadap entitas.
    *   `usecases/`: Logika bisnis spesifik (contoh: `GetRemindersUseCase`, `LoginUseCase`).
*   **`data/`**: Lapisan implementasi data.
    *   `models/`: Ekstensi dari entity yang menambahkan fungsi serialisasi (JSON/Map to Object).
    *   `datasources/`: Sumber data yang sebenarnya (Database SQLite lokal, HTTP client untuk API eksternal).
    *   `repositories/`: Implementasi dari repository interface yang ada di lapisan domain.
*   **`features/`**: Lapisan Presentasi (UI/UX) tempat semua layar aplikasi berada. Masing-masing folder mewakili satu fitur dan umumnya memiliki folder `providers/` (State Management), halaman UI `.dart`, dan widget khusus.

---

## 2. Alur Kerja (Workflow) Fitur-Fitur Utama

Berikut adalah penjelasan rute dan alur untuk setiap fitur utama di aplikasi ini:

### A. Autentikasi (Authentication)
*   **Alur:** Pengguna membuka aplikasi dan GoRouter (`AppRouter`) akan mengecek status `isAuthenticated` dari `AuthProvider`. Jika belum login, diarahkan ke `LoginPage`.
*   **Fitur:** Aplikasi mendukung login manual, pendaftaran akun (`RegisterPage`), dan juga _Biometric Authentication_ (Sidik jari/Face ID) menggunakan `local_auth`. Password akan di-hash menggunakan SHA-256 untuk keamanan.

### B. Dashboard / Home (`MainPage`)
*   **Alur:** Setelah login, pengguna masuk ke `MainPage`. Ini adalah halaman utama yang berfungsi sebagai kerangka navigasi (Bottom Navigation Bar) untuk berpindah ke tab Notes, Tools, dan Profile.

### C. Manajemen Catatan (Notes)
*   **Alur:** Pengguna melihat daftar catatan di `NotesPage`. Data diambil melalui `NotesProvider` yang memanggil Use Case di lapisan `domain/`, yang pada akhirnya mengambil data dari SQLite via `data/`.
*   **Fitur:** CRUD (Create, Read, Update, Delete). Menambah/edit catatan dilakukan di `NoteFormPage`. Terdapat juga integrasi "Smart Assist" AI yang dapat meringkas atau menganalisis catatan pengguna.

### D. Fitur Alat Pintar (Tools Dashboard)
Kumpulan utilitas yang diakses melalui `ToolsPage`.
*   **Cuaca (Weather):** Memanggil OpenWeatherAPI menggunakan `dio`/`http`. Alur: Meminta akses lokasi (`geolocator`), lalu mengambil data cuaca berdasarkan koordinat saat ini.
*   **Konversi Mata Uang & Waktu:** Form untuk mengonversi nilai tukar atau perbedaan zona waktu.
*   **Daily Focus (Memory Match Game):** Sebuah mini-game mencocokkan kartu untuk melatih daya ingat.
*   **Asisten AI (Chatbot):** Fitur obrolan dengan AI (`OllamaService`) yang disetel khusus dengan prompt sistem untuk membantu pengguna bernavigasi dan menggunakan fitur aplikasi.
*   **Manajemen Pengingat (Reminders):** Menggunakan `flutter_local_notifications` dan `timezone` untuk menjadwalkan notifikasi alarm lokal di HP pengguna.

### E. Profil (Profile & Settings)
*   **Alur:** Menampilkan informasi pengguna. Memiliki fitur update foto (menggunakan `image_picker`), form masukan (Feedback), dan fungsi Logout yang akan menghapus session di `flutter_secure_storage`.
*   **Sensor Deteksi:** Aplikasi ini memiliki `ShakeDetectorWrapper` yang menggunakan sensor `sensors_plus` (Accelerometer) sehingga jika HP digoyangkan dengan keras, dapat memicu aksi tertentu (misalnya shortcut pelaporan bug atau feedback).

---

## 3. Penjelasan Rinci: Fungsi File dan Baris Kode

Untuk memberikan gambaran "sangat amat teramat rinci", mari kita bedah dua file penting yang menjadi urat nadi aplikasi ini.

### A. Konfigurasi Routing: `lib/core/router/app_router.dart`

File ini bertugas mengontrol lalu lintas perpindahan halaman aplikasi dan melindungi rute agar tidak diakses tanpa login.

```dart
// [Baris 30] Membuat konfigurasi router dengan GoRouter
static GoRouter router(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: login, // Titik masuk awal aplikasi adalah route '/login'
    refreshListenable: authProvider, // Router akan me-rebuild ulang jika status auth berubah (misal tiba-tiba logout)
    
    // [Baris 35] Logic redirect (Penjaga Rute / Guard)
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == login || state.matchedLocation == register;

      // Jika sudah login tapi mencoba ke halaman login/register, paksa arahkan ke '/home'
      if (isLoggedIn && isAuthRoute) return home;
      
      // Jika belum login tapi mencoba akses rute dalam (seperti '/home' atau '/notes'), paksa arahkan ke '/login'
      if (!isLoggedIn && !isAuthRoute) return login;

      return null; // Null berarti rute diizinkan
    },
    // Definisi rute lainnya...
```

### B. Logika Integrasi AI: `lib/features/ai/ollama_service.dart`

File ini mengatur bagaimana aplikasi berkomunikasi dengan AI model (Ollama) baik untuk fitur Chatbot maupun Smart Notes.

```dart
// [Baris 13-26] Model Data
// Mendefinisikan struktur data untuk model Ollama yang tersedia (nama model, dan daftar server yang menyediakannya)
class OllamaModel { ... }

// [Baris 36] OllamaService
// Kelas utama yang menangani pemanggilan API HTTP ke server AI.
class OllamaService {
  OllamaService(this._client); // Injeksi dependensi HTTP Client
  
  // [Baris 108] sendMessage() - Fungsi pengirim pesan biasa
  Future<String> sendMessage(String text, {String model = defaultModel}) async {
    final ollamaModel = _findModel(model); 
    // ... [Baris 116] Mengurutkan server dari yang performanya paling cepat (tokensPerSecond tertinggi)
    final servers = List<OllamaServer>.from(ollamaModel.servers)
      ..sort((a, b) => b.tokensPerSecond.compareTo(a.tokensPerSecond));

    // [Baris 120] Fallback Mechanism (Coba satu-satu)
    for (final server in servers) {
      try {
        // Mencoba memanggil server A. Jika server A down atau error, dia akan masuk ke catch dan mencoba server B.
        final response = await _callServer(
          serverUrl: server.url,
          model: model,
          prompt: _buildPrompt(text),
        );
        return response; // Jika sukses, langsung kembalikan respons
      } catch (_) {
        continue; // Lanjut iterasi ke server berikutnya
      }
    }
    // [Baris 135] Jika semua server gagal karena tidak ada koneksi internet, gunakan jawaban offline
    return _offlineFallback(text);
  }

  // [Baris 182] _buildPrompt() - System Prompt Injection
  // Baris ini sangat penting. Sebelum pertanyaan pengguna dikirim ke AI, kita menyuntikkan instruksi khusus agar AI tahu identitasnya.
  String _buildPrompt(String userMessage) {
    return '''Kamu adalah asisten AI dalam aplikasi Smart Daily Assistant... 
Pengguna: $userMessage
Asisten:''';
  }
}
```

### Ringkasan Teknis (Tech Stack)
*   **State Management:** `provider` (Digunakan di file `main.dart` dengan `MultiProvider`).
*   **Dependency Injection:** `get_it` (Digunakan di `ServiceLocator` untuk inisialisasi kelas secara singleton).
*   **Navigasi:** `go_router` (Deklaratif routing).
*   **Penyimpanan:** `sqflite` (Database relasional), `flutter_secure_storage` (Menyimpan token aman), `shared_preferences`.
*   **Utilitas:** `intl` (Format tanggal id_ID), `shimmer` & `lottie` (Animasi loading).
