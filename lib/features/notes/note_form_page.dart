import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/note_entity.dart';
import 'providers/notes_provider.dart';
import '../../core/di/service_locator.dart';
import '../ai/ollama_service.dart';
import '../ai/models/smart_note_result.dart';

class NoteFormPage extends StatefulWidget {
  final NoteEntity? noteToEdit;

  const NoteFormPage({super.key, this.noteToEdit});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;
  bool _isAnalyzing = false;

  bool get isEditing => widget.noteToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.noteToEdit?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<NotesProvider>();
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    bool success;
    if (isEditing) {
      success = await provider.updateNote(
        widget.noteToEdit!.id!,
        title,
        content,
        widget.noteToEdit!.createdAt,
      );
    } else {
      success = await provider.addNote(title, content);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Catatan diperbarui!' : 'Catatan ditambahkan!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan catatan'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSmartAssist() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan masih kosong. Isi catatan terlebih dahulu!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final ollamaService = ServiceLocator.sl<OllamaService>();
      final result = await ollamaService.analyzeNote(content);

      if (!mounted) return;

      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Gagal menganalisis catatan'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        _showSmartAssistBottomSheet(result);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses AI.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showSmartAssistBottomSheet(SmartNoteResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.primary),
                          SizedBox(width: AppSizes.sm),
                          Text(
                            'Smart Note Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: AppSizes.xl),
                  
                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        if (result.summary.isNotEmpty) ...[
                          _buildSectionTitle(Icons.description, 'Ringkasan'),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            result.summary,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],
                        if (result.keyPoints.isNotEmpty) ...[
                          _buildSectionTitle(Icons.format_list_bulleted, 'Poin Penting'),
                          const SizedBox(height: AppSizes.sm),
                          ...result.keyPoints.map((point) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: const TextStyle(fontSize: 16, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: AppSizes.lg),
                        ],
                        if (result.suggestions.isNotEmpty) ...[
                          _buildSectionTitle(Icons.lightbulb_outline, 'Saran Tindakan'),
                          const SizedBox(height: AppSizes.sm),
                          ...result.suggestions.map((sug) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                                const SizedBox(width: AppSizes.xs),
                                Expanded(
                                  child: Text(
                                    sug,
                                    style: const TextStyle(fontSize: 16, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isAnalyzing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _handleSmartAssist,
              icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
              label: const Text('Smart Assist', style: TextStyle(color: AppColors.primary)),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.primary),
              onPressed: _saveNote,
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Title Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Judul Catatan',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
            
            // Divider
            const Divider(height: 1, color: AppColors.divider),
            
            // Content Input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: TextFormField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Mulai mengetik...',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.textHint.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
