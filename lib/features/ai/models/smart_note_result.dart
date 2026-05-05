class SmartNoteResult {
  final String summary;
  final List<String> keyPoints;
  final List<String> suggestions;
  final bool hasError;
  final String? errorMessage;

  SmartNoteResult({
    required this.summary,
    required this.keyPoints,
    required this.suggestions,
    this.hasError = false,
    this.errorMessage,
  });

  /// Factory untuk membuat result error
  factory SmartNoteResult.error(String message) {
    return SmartNoteResult(
      summary: '',
      keyPoints: [],
      suggestions: [],
      hasError: true,
      errorMessage: message,
    );
  }

  /// Parser untuk mengubah raw text balasan LLM menjadi objek SmartNoteResult
  factory SmartNoteResult.parse(String rawText) {
    try {
      if (rawText.trim().isEmpty) {
        return SmartNoteResult.error('Respons kosong dari asisten AI.');
      }

      String summary = '';
      List<String> keyPoints = [];
      List<String> suggestions = [];

      // Memecah berdasarkan baris
      final lines = rawText.split('\n');
      
      String currentSection = '';

      for (var line in lines) {
        final lowerLine = line.trim().toLowerCase();

        // Cek perpindahan section
        if (lowerLine.startsWith('ringkasan:')) {
          currentSection = 'summary';
          var text = line.substring('ringkasan:'.length).trim();
          if (text.isNotEmpty) summary += text;
          continue;
        } else if (lowerLine.startsWith('poin penting:')) {
          currentSection = 'keypoints';
          var text = line.substring('poin penting:'.length).trim();
          if (text.isNotEmpty) keyPoints.add(_cleanBullet(text));
          continue;
        } else if (lowerLine.startsWith('saran:')) {
          currentSection = 'suggestions';
          var text = line.substring('saran:'.length).trim();
          if (text.isNotEmpty) suggestions.add(_cleanBullet(text));
          continue;
        }

        // Isi section berdasarkan state saat ini
        if (line.trim().isEmpty) continue;

        if (currentSection == 'summary') {
          if (summary.isNotEmpty) summary += ' ';
          summary += line.trim();
        } else if (currentSection == 'keypoints') {
          keyPoints.add(_cleanBullet(line));
        } else if (currentSection == 'suggestions') {
          suggestions.add(_cleanBullet(line));
        } else {
          // Jika tidak ada awalan section tapi ada teks di awal, asumsikan itu ringkasan
          if (currentSection.isEmpty) {
            currentSection = 'summary';
            summary += line.trim();
          }
        }
      }

      // Bersihkan list dari item kosong
      keyPoints.removeWhere((e) => e.isEmpty);
      suggestions.removeWhere((e) => e.isEmpty);

      // Jika format sama sekali tidak ketemu, set raw text ke summary
      if (summary.isEmpty && keyPoints.isEmpty && suggestions.isEmpty) {
        summary = rawText.trim();
      }

      return SmartNoteResult(
        summary: summary,
        keyPoints: keyPoints,
        suggestions: suggestions,
      );
    } catch (e) {
      return SmartNoteResult.error('Gagal memproses respons AI: $e');
    }
  }

  /// Helper untuk membersihkan simbol bullet (*, -, 1., dll) di awal string
  static String _cleanBullet(String text) {
    var cleaned = text.trim();
    // Hapus karakter awal seperti '* ', '- ', '1. ', dll.
    cleaned = cleaned.replaceFirst(RegExp(r'^[\*\-\+]\s*'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    return cleaned.trim();
  }
}
