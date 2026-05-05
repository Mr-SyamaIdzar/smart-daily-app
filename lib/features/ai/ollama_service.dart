import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/smart_note_result.dart';
/// Model data untuk satu server Ollama publik.
class OllamaServer {
  final String url;
  final double tokensPerSecond;

  const OllamaServer({required this.url, required this.tokensPerSecond});
}

/// Model yang tersedia di OllamaFreeAPI.
class OllamaModel {
  final String name;
  final String displayName;
  final String family;
  final List<OllamaServer> servers;

  const OllamaModel({
    required this.name,
    required this.displayName,
    required this.family,
    required this.servers,
  });
}

/// Service yang memanggil server Ollama publik dari OllamaFreeAPI
/// secara langsung via HTTP REST API.
///
/// Server dan model diambil dari data JSON yang sama dengan
/// paket Python OllamaFreeAPI (https://github.com/mfoud444/ollamafreeapi).
///
/// Endpoint: POST {server}/api/generate
/// Payload:  { "model": "...", "prompt": "...", "stream": false, "options": {...} }
class OllamaService {
  OllamaService(this._client);

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 45);

  // ─── Daftar server & model dari OllamaFreeAPI JSON data ───────────────────
  // Data diambil dari: github.com/mfoud444/ollamafreeapi/ollamafreeapi/ollama_json/
  // Server diurutkan berdasarkan perf_tokens_per_second (descending).

  static const List<OllamaModel> availableModels = [
    OllamaModel(
      name: 'smollm2:135m',
      displayName: 'SmolLM2 135M (Tercepat)',
      family: 'llama',
      servers: [
        OllamaServer(url: 'http://172.236.213.60:11434', tokensPerSecond: 74.92),
        OllamaServer(url: 'http://108.181.196.208:11434', tokensPerSecond: 9.27),
      ],
    ),
    OllamaModel(
      name: 'llama3.2:3b',
      displayName: 'LLaMA 3.2 3B',
      family: 'llama',
      servers: [
        OllamaServer(url: 'http://172.236.213.60:11434', tokensPerSecond: 74.92),
        OllamaServer(url: 'http://5.149.249.212:11434', tokensPerSecond: 13.01),
        OllamaServer(url: 'http://89.111.170.212:11434', tokensPerSecond: 14.06),
        OllamaServer(url: 'http://185.211.5.32:11434', tokensPerSecond: 8.10),
        OllamaServer(url: 'http://108.181.196.208:11434', tokensPerSecond: 9.27),
      ],
    ),
    OllamaModel(
      name: 'llama3.2:latest',
      displayName: 'LLaMA 3.2 Latest',
      family: 'llama',
      servers: [
        OllamaServer(url: 'http://172.236.213.60:11434', tokensPerSecond: 74.92),
      ],
    ),
    OllamaModel(
      name: 'llama3:latest',
      displayName: 'LLaMA 3 8B',
      family: 'llama',
      servers: [
        OllamaServer(url: 'http://108.181.196.208:11434', tokensPerSecond: 9.27),
      ],
    ),
    OllamaModel(
      name: 'mistral:latest',
      displayName: 'Mistral 7B',
      family: 'llama',
      servers: [
        OllamaServer(url: 'http://172.236.213.60:11434', tokensPerSecond: 74.92),
      ],
    ),
    OllamaModel(
      name: 'mistral-nemo:custom',
      displayName: 'Mistral Nemo 12B',
      family: 'llama',
      servers: [
        OllamaServer(url: 'http://5.149.249.212:11434', tokensPerSecond: 13.01),
      ],
    ),
  ];

  /// Model default yang digunakan saat pertama kali buka chat.
  static const String defaultModel = 'llama3.2:3b';

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Kirim pesan dan dapatkan respons lengkap (non-streaming).
  /// Mencoba server-server yang tersedia satu per satu berdasarkan performa.
  Future<String> sendMessage(String text, {String model = defaultModel}) async {
    final ollamaModel = _findModel(model);
    if (ollamaModel == null) {
      return _offlineFallback(text);
    }

    // Urutkan server berdasarkan tokensPerSecond (descending)
    final servers = List<OllamaServer>.from(ollamaModel.servers)
      ..sort((a, b) => b.tokensPerSecond.compareTo(a.tokensPerSecond));

    for (final server in servers) {
      try {
        final response = await _callServer(
          serverUrl: server.url,
          model: model,
          prompt: _buildPrompt(text),
        );
        return response;
      } catch (_) {
        // Coba server berikutnya
        continue;
      }
    }

    // Semua server gagal → fallback offline
    return _offlineFallback(text);
  }

  /// Stream respons secara real-time (chunk by chunk).
  Stream<String> streamMessage(String text, {String model = defaultModel}) async* {
    final ollamaModel = _findModel(model);
    if (ollamaModel == null) {
      yield _offlineFallback(text);
      return;
    }

    final servers = List<OllamaServer>.from(ollamaModel.servers)
      ..sort((a, b) => b.tokensPerSecond.compareTo(a.tokensPerSecond));

    for (final server in servers) {
      try {
        final buffer = StringBuffer();
        await for (final chunk in _streamServer(
          serverUrl: server.url,
          model: model,
          prompt: _buildPrompt(text),
        )) {
          buffer.write(chunk);
          yield chunk;
        }
        return; // Stream berhasil
      } catch (_) {
        // Coba server berikutnya
        continue;
      }
    }

    // Semua gagal
    yield _offlineFallback(text);
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  OllamaModel? _findModel(String modelName) {
    try {
      return availableModels.firstWhere((m) => m.name == modelName);
    } catch (_) {
      return null;
    }
  }

  /// Membangun prompt dengan system instruction dalam bahasa Indonesia.
  String _buildPrompt(String userMessage) {
    return '''Kamu adalah asisten AI eksklusif dalam aplikasi Smart Daily Assistant. Tugasmu HANYA membantu pengguna menggunakan fitur aplikasi: Notes/Catatan, Cuaca, Konversi Waktu, Konversi Mata Uang, Notifikasi, Daily Focus (Memory Match game), dan Profil.
JANGAN menjawab atau merespons pertanyaan di luar konteks aplikasi atau topik-topik di atas. Jika ditanya hal lain, katakan "Maaf, aku hanya bisa membantu terkait fitur-fitur Smart Daily Assistant."
Jawab dalam bahasa Indonesia yang ramah dan singkat.

Pengguna: $userMessage

Asisten:''';
  }

  /// Membangun prompt khusus untuk fitur Smart Note Assistant.
  String _buildSmartNotePrompt(String noteContent) {
    return '''Kamu adalah asisten AI yang membantu pengguna memahami catatan mereka.
Tugas kamu:
1. Buat ringkasan singkat dari catatan
2. Ambil poin-poin penting secara dinamis (jangan dibatasi jumlahnya)
3. Berikan saran tindakan secara dinamis jika ada

Aturan:
* Gunakan Bahasa Indonesia
* Jawaban maksimal 5 kalimat untuk ringkasan
* WAJIB gunakan format persis seperti di bawah ini:

Ringkasan:
(isi ringkasan di sini)

Poin Penting:
* (poin penting 1)
* (poin penting 2)
* ... (dan seterusnya, dinamis menyesuaikan isi catatan)

Saran:
* (saran tindakan 1)
* (saran tindakan 2)
* ... (dan seterusnya, dinamis menyesuaikan isi catatan)

Jika catatan kosong atau tidak jelas, jawab dengan sopan bahwa kamu tidak bisa menemukan informasi penting.

Catatan Pengguna:
"""
$noteContent
"""''';
  }

  /// Menganalisis konten catatan dan mengembalikan objek terstruktur.
  Future<SmartNoteResult> analyzeNote(String noteContent) async {
    try {
      final ollamaModel = _findModel(defaultModel) ?? availableModels.first;
      final servers = List<OllamaServer>.from(ollamaModel.servers)
        ..sort((a, b) => b.tokensPerSecond.compareTo(a.tokensPerSecond));

      String? responseText;

      for (final server in servers) {
        try {
          responseText = await _callServer(
            serverUrl: server.url,
            model: defaultModel,
            prompt: _buildSmartNotePrompt(noteContent),
          );
          if (responseText.isNotEmpty) break;
        } catch (_) {
          continue; // Coba server berikutnya
        }
      }

      if (responseText == null || responseText.isEmpty) {
        return SmartNoteResult.error('Gagal menghubungi server AI. Silakan coba lagi nanti.');
      }

      return SmartNoteResult.parse(responseText);
    } on TimeoutException {
      return SmartNoteResult.error('Waktu permintaan habis (timeout). Periksa koneksi internet Anda.');
    } catch (e) {
      return SmartNoteResult.error('Terjadi kesalahan yang tidak terduga: \$e');
    }
  }

  /// Panggil Ollama REST API (non-streaming).
  Future<String> _callServer({
    required String serverUrl,
    required String model,
    required String prompt,
  }) async {
    final uri = Uri.parse('$serverUrl/api/generate');
    final body = jsonEncode({
      'model': model,
      'prompt': prompt,
      'stream': false,
      'options': {
        'temperature': 0.7,
        'top_p': 0.9,
        'num_predict': 512,
      },
    });

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (json['response'] as String? ?? '').trim();
      if (text.isEmpty) throw Exception('Respons kosong dari server');
      return text;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Panggil Ollama REST API (streaming — NDJSON).
  Stream<String> _streamServer({
    required String serverUrl,
    required String model,
    required String prompt,
  }) async* {
    final uri = Uri.parse('$serverUrl/api/generate');
    final body = jsonEncode({
      'model': model,
      'prompt': prompt,
      'stream': true,
      'options': {
        'temperature': 0.7,
        'top_p': 0.9,
        'num_predict': 512,
      },
    });

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = body;

    final streamedResponse = await _client.send(request).timeout(_timeout);

    if (streamedResponse.statusCode != 200) {
      throw Exception('HTTP ${streamedResponse.statusCode}');
    }

    await for (final chunk in streamedResponse.stream
        .timeout(_timeout)
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (chunk.isEmpty) continue;
      try {
        final json = jsonDecode(chunk) as Map<String, dynamic>;
        final token = json['response'] as String? ?? '';
        if (token.isNotEmpty) yield token;
        if (json['done'] == true) break;
      } catch (_) {
        // Baris JSON tidak valid, lewati
        continue;
      }
    }
  }

  // ─── Offline fallback (sama dengan implementasi sebelumnya) ───────────────

  String _offlineFallback(String text) {
    final q = text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    if (_matchAny(q, [RegExp(r'^(hi|hai|halo|hello)\b'), RegExp(r'\bass?alam')])) {
      return 'Halo! Aku asisten Smart Daily App. Ada yang bisa kubantu terkait fitur aplikasi?';
    }
    if (_matchAny(q, [RegExp(r'\b(fitur|menu|help|bantuan)\b'), RegExp(r'cara pakai')])) {
      return 'Fitur yang tersedia:\n1) Notes – tambah, edit, cari catatan\n2) Tools – Cuaca, Konversi Waktu, Mata Uang, Notifikasi\n3) Daily Focus – Memory Match game\n\nTanya lebih lanjut, misalnya: "cara pakai cuaca".';
    }
    if (_matchAny(q, [RegExp(r'\bcuaca\b'), RegExp(r'\bweather\b')])) {
      return 'Buka Tools → Cuaca. Pastikan izin lokasi aktif untuk deteksi otomatis, atau ketik nama kota secara manual.';
    }
    if (_matchAny(q, [RegExp(r'\b(catatan|notes?)\b')])) {
      return 'Menu Notes: tekan + untuk tambah catatan, tap catatan untuk edit, atau gunakan fitur cari di atas.';
    }
    if (_matchAny(q, [RegExp(r'\b(notifikasi|pengingat)\b')])) {
      return 'Buka Tools → Notifikasi. Pastikan izin notifikasi aktif di pengaturan perangkat.';
    }
    if (_matchAny(q, [RegExp(r'\bdaily\s*focus\b'), RegExp(r'\bmemory\s*match\b'), RegExp(r'\bgame\b')])) {
      return 'Daily Focus adalah mini game Memory Match. Buka via Tools → Daily Focus. Cocokkan pasangan kartu dengan gerakan sesedikit mungkin!';
    }
    if (_matchAny(q, [RegExp(r'\b(mata\s*uang|kurs|currency)\b')])) {
      return 'Konversi Mata Uang ada di Tools → Mata Uang. Pilih mata uang asal & tujuan, lalu masukkan jumlah.';
    }
    if (_matchAny(q, [RegExp(r'\bkonversi\b.*\bwaktu\b'), RegExp(r'\btime\s*converter\b')])) {
      return 'Konversi Waktu ada di Tools → Konversi Waktu untuk mengubah zona waktu antar kota.';
    }

    return 'Maaf, koneksi ke AI sedang tidak tersedia. Kamu bisa tanya tentang: cuaca, catatan, notifikasi, konversi waktu/mata uang, atau Daily Focus.';
  }

  bool _matchAny(String q, List<RegExp> patterns) =>
      patterns.any((p) => p.hasMatch(q));
}
