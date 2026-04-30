import 'package:flutter/material.dart';
import '../ollama_service.dart';
import '../chat_model.dart';

class ChatProvider with ChangeNotifier {
  final OllamaService _ollamaService;

  ChatProvider(this._ollamaService);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isCooldown = false;
  bool _isStreaming = false;
  String _currentModel = OllamaService.defaultModel;
  String _streamingText = '';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isCooldown => _isCooldown;
  bool get isStreaming => _isStreaming;
  String get currentModel => _currentModel;
  String get streamingText => _streamingText;

  List<OllamaModel> get availableModels => OllamaService.availableModels;

  void setModel(String modelName) {
    _currentModel = modelName;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _isCooldown) return;

    // Tambah pesan user
    _messages.add(ChatMessage(text: text, role: MessageRole.user));
    _isLoading = true;
    _isStreaming = false;
    _streamingText = '';
    notifyListeners();

    try {
      // Gunakan streaming
      _isStreaming = true;
      final buffer = StringBuffer();

      await for (final chunk in _ollamaService.streamMessage(
        text,
        model: _currentModel,
      )) {
        buffer.write(chunk);
        _streamingText = buffer.toString();
        notifyListeners();
      }

      final finalText = buffer.toString().trim();
      _messages.add(ChatMessage(
        text: finalText.isEmpty ? 'Maaf, tidak ada respons dari server.' : finalText,
        role: MessageRole.model,
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Maaf, terjadi masalah koneksi. Silakan coba lagi.',
        role: MessageRole.model,
      ));
    } finally {
      _isLoading = false;
      _isStreaming = false;
      _streamingText = '';
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _streamingText = '';
    notifyListeners();
  }
}
