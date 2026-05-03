import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../reminders/providers/reminder_provider.dart';
import '../reminders/reminder_form_page.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<ReminderProvider>().loadReminders(userId);
    }
  }

  Future<void> _confirmDelete(BuildContext context, ReminderEntity reminder) async {
    // Simpan referensi sebelum async gap
    final reminderProvider = context.read<ReminderProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 10),
            Text('Hapus Reminder?'),
          ],
        ),
        content: Text(
          'Reminder "${reminder.title}" akan dihapus dan notifikasinya dibatalkan.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await reminderProvider.deleteReminder(reminder.id!);
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('🗑️ Reminder dihapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.status == ReminderStatus.error) {
            return _buildErrorState(provider.errorMessage);
          }

          return Column(
            children: [
              _buildSummaryBar(provider),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReminderList(provider.upcomingReminders,
                        isUpcoming: true),
                    _buildReminderList(provider.pastReminders,
                        isUpcoming: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Reminder Saya'),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Consumer<ReminderProvider>(
          builder: (_, provider, __) {
            if (provider.reminders.isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBar(ReminderProvider provider) {
    final upcoming = provider.upcomingReminders.length;
    final past = provider.pastReminders.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatChip(
            icon: Icons.upcoming_rounded,
            label: 'Akan Datang',
            count: upcoming,
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white30,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildStatChip(
            icon: Icons.history_rounded,
            label: 'Sudah Lewat',
            count: past,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: '🔔 Akan Datang'),
          Tab(text: '📋 Riwayat'),
        ],
      ),
    );
  }

  Widget _buildReminderList(
    List<ReminderEntity> reminders, {
    required bool isUpcoming,
  }) {
    if (reminders.isEmpty) {
      return _buildEmptyState(isUpcoming: isUpcoming);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _ReminderCard(
          reminder: reminder,
          isUpcoming: isUpcoming,
          onDelete: () => _confirmDelete(context, reminder),
        );
      },
    );
  }

  Widget _buildEmptyState({required bool isUpcoming}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUpcoming
                    ? Icons.add_alarm_rounded
                    : Icons.history_toggle_off_rounded,
                size: 48,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isUpcoming ? 'Belum Ada Reminder' : 'Belum Ada Riwayat',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Ketuk tombol + untuk menambahkan\nreminder pertama Anda!'
                  : 'Reminder yang sudah terlewat\nakan muncul di sini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReminderFormPage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Buat Reminder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReminderFormPage()),
        );
        _loadData(); // Refresh setelah kembali dari form
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_alarm_rounded),
      label: const Text(
        'Tambah Reminder',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Reminder Card Widget ──────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final ReminderEntity reminder;
  final bool isUpcoming;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.isUpcoming,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = reminder.dateTime.year == now.year &&
        reminder.dateTime.month == now.month &&
        reminder.dateTime.day == now.day;

    final dateStr = isToday
        ? 'Hari ini'
        : DateFormat('EEE, dd MMM yyyy', 'id_ID').format(reminder.dateTime);
    final timeStr = DateFormat('HH:mm').format(reminder.dateTime);

    // Hitung sisa waktu
    final diff = reminder.dateTime.difference(now);
    String countdownStr = '';
    if (isUpcoming) {
      if (diff.inDays > 0) {
        countdownStr = '${diff.inDays} hari lagi';
      } else if (diff.inHours > 0) {
        countdownStr = '${diff.inHours} jam lagi';
      } else if (diff.inMinutes > 0) {
        countdownStr = '${diff.inMinutes} menit lagi';
      } else {
        countdownStr = 'Sebentar lagi';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUpcoming ? AppColors.border : AppColors.divider,
          width: isUpcoming ? 1 : 0.5,
        ),
        boxShadow: isUpcoming
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUpcoming
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUpcoming
                    ? Icons.alarm_rounded
                    : Icons.alarm_off_rounded,
                color: isUpcoming ? AppColors.primary : AppColors.textHint,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + countdown chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isUpcoming
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUpcoming && countdownStr.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            countdownStr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    reminder.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Date & time row
                  Row(
                    children: [
                      _buildChip(
                        icon: Icons.calendar_today_rounded,
                        label: dateStr,
                        isUpcoming: isUpcoming,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        icon: Icons.access_time_rounded,
                        label: timeStr,
                        isUpcoming: isUpcoming,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.error.withOpacity(0.7),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required bool isUpcoming,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUpcoming ? AppColors.surfaceVariant : AppColors.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isUpcoming ? AppColors.primary : AppColors.textHint,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isUpcoming ? AppColors.textSecondary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
