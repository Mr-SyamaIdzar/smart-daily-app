import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../reminders/providers/reminder_provider.dart';

class ReminderFormPage extends StatefulWidget {
  const ReminderFormPage({super.key});

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Date & Time Pickers ───────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // ── Validation & Save ─────────────────────────────────────────────────────

  DateTime? get _combinedDateTime {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  String? _validateDateTime() {
    if (_selectedDate == null) return 'Pilih tanggal terlebih dahulu';
    if (_selectedTime == null) return 'Pilih waktu terlebih dahulu';
    final combined = _combinedDateTime!;
    if (combined.isBefore(DateTime.now())) {
      return 'Waktu tidak boleh di masa lalu';
    }
    return null;
  }

  Future<void> _save() async {
    final dateTimeError = _validateDateTime();

    if (!_formKey.currentState!.validate() || dateTimeError != null) {
      if (dateTimeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dateTimeError),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi tidak valid, silakan login ulang.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reminderProvider = context.read<ReminderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await reminderProvider.addReminder(
          userId: userId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dateTime: _combinedDateTime!,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Reminder berhasil disimpan!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pop();
    } else {
      final err = reminderProvider.errorMessage;
      messenger.showSnackBar(
        SnackBar(
          content: Text(err.isNotEmpty ? err : 'Gagal menyimpan reminder.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBanner(),
                const SizedBox(height: 24),
                _buildSectionLabel('Detail Reminder'),
                const SizedBox(height: 12),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDescField(),
                const SizedBox(height: 24),
                _buildSectionLabel('Jadwal'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDatePickerCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTimePickerCard()),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Tambah Reminder'),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.add_alarm_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Pengingat Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Isi detail dan jadwal reminder Anda',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Judul Reminder',
        hintText: 'Contoh: Meeting tim, Minum obat...',
        prefixIcon: const Icon(
          Icons.title_rounded,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Judul tidak boleh kosong';
        if (v.trim().length < 3) return 'Judul minimal 3 karakter';
        return null;
      },
    );
  }

  Widget _buildDescField() {
    return TextFormField(
      controller: _descController,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Deskripsi',
        hintText: 'Tambahkan detail reminder Anda...',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.notes_rounded, color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Deskripsi tidak boleh kosong';
        return null;
      },
    );
  }

  Widget _buildDatePickerCard() {
    final hasDate = _selectedDate != null;
    return GestureDetector(
      onTap: _pickDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: hasDate
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          border: Border.all(
            color: hasDate ? AppColors.primary : AppColors.border,
            width: hasDate ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: hasDate ? AppColors.primary : AppColors.textHint,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              hasDate
                  ? DateFormat('EEE,\ndd MMM yyyy', 'id_ID')
                      .format(_selectedDate!)
                  : 'Pilih\nTanggal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasDate ? AppColors.primary : AppColors.textHint,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerCard() {
    final hasTime = _selectedTime != null;
    final timeStr = hasTime ? _selectedTime!.format(context) : null;
    return GestureDetector(
      onTap: _pickTime,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: hasTime
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          border: Border.all(
            color: hasTime ? AppColors.primary : AppColors.border,
            width: hasTime ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: hasTime ? AppColors.primary : AppColors.textHint,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              hasTime ? timeStr! : 'Pilih\nWaktu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: hasTime ? 16 : 12,
                fontWeight: FontWeight.w700,
                color: hasTime ? AppColors.primary : AppColors.textHint,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Reminder',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
