import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/notification_service.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final _notificationService = ServiceLocator.sl<NotificationService>();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notifications'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Notifikasi Manual',
              description: 'Klik tombol di bawah untuk memicu notifikasi instan.',
              icon: Icons.notification_important,
              buttonLabel: 'Kirim Sekarang',
              onPressed: () {
                _notificationService.showNotification(
                  title: 'Halo!',
                  body: 'Ini adalah notifikasi manual yang Anda picu.',
                  payload: 'manual_payload',
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Pengingat Harian',
              description: 'Atur waktu untuk menerima notifikasi setiap hari.',
              icon: Icons.alarm,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Waktu Pengingat'),
                    trailing: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _notificationService.scheduleDailyNotification(
                        title: 'Pengingat Harian',
                        body: 'Jangan lupa cek tugas Anda hari ini!',
                        hour: _selectedTime.hour,
                        minute: _selectedTime.minute,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pengingat dijadwalkan setiap hari pukul ${_selectedTime.format(context)}',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Jadwalkan Pengingat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                _notificationService.cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua notifikasi dibatalkan.')),
                );
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Batalkan Semua Notifikasi', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required IconData icon,
    String? buttonLabel,
    VoidCallback? onPressed,
    Widget? child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            if (buttonLabel != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }
}
