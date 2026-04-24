import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final http.Client _client;
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';

  GeminiService(this._client);

  final String _systemInstruction = """
Kamu adalah asisten dalam aplikasi Smart Daily Assistant App.
Tugasmu hanya membantu pengguna memahami dan menggunakan fitur dalam aplikasi ini seperti catatan, cuaca, konversi mata uang, konversi waktu, chatbot, game, dan profil.
Jangan menjawab pertanyaan di luar konteks aplikasi.
Jika pertanyaan tidak relevan, jawab dengan sopan bahwa kamu hanya bisa membantu terkait aplikasi ini.
Jawaban harus singkat, jelas, dan maksimal 3-5 kalimat.
""";

  Future<String> sendMessage(String message) async {
    final apiKey = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    if (apiKey.isEmpty) {
      return 'Error: API Key Gemini tidak ditemukan. Pastikan GEMINI_API_KEY sudah ditambahkan di file .env.';
    }

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {              // ✅ camelCase
            'parts': [
              {'text': _systemInstruction}
            ]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': message}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List? ?? [];
        if (candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'];
          return text.toString().trim();
        }
        return 'Maaf, saya tidak mendapatkan respons dari AI.';
      } else if (response.statusCode == 429) {
        return 'Batas request AI tercapai. Tunggu beberapa saat lalu coba lagi.';
      } else {
        return 'Gagal menghubungi AI (Status: ${response.statusCode}).';
      }
    } catch (e) {
      return 'Terjadi kesalahan koneksi: $e';
    }
  }
}