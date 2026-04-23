import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/note_entity.dart';
import 'providers/notes_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
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
