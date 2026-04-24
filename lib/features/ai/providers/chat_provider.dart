import 'package:flutter/material.dart';
import '../gemini_service.dart';
import '../chat_model.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService;

  ChatProvider(this._geminiService);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isCooldown = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isCooldown => _isCooldown;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _isCooldown) return;

    // Add user message
    _messages.add(ChatMessage(text: text, role: MessageRole.user));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _geminiService.sendMessage(text);
      _messages.add(ChatMessage(text: response, role: MessageRole.model));

      // Cek jika response adalah 429 (Batas request tercapai)
      if (response.contains('Batas request AI tercapai')) {
        _triggerCooldown();
      }
    } catch (e) {
      _messages.add(ChatMessage(
        text: "Maaf, terjadi masalah koneksi. Silakan coba lagi.",
        role: MessageRole.model,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _triggerCooldown() async {
    _isCooldown = true;
    notifyListeners();
    
    // Tunggu 10 detik sebelum mengaktifkan kembali
    await Future.delayed(const Duration(seconds: 10));
    
    _isCooldown = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
