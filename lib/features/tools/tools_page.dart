import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools Dashboard'),
      ),
      backgroundColor: AppColors.background,
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(AppSizes.lg),
        mainAxisSpacing: AppSizes.md,
        crossAxisSpacing: AppSizes.md,
        children: [
          _buildToolCard(
            context,
            title: 'Cuaca',
            icon: Icons.cloud_queue,
            color: AppColors.primary,
            onTap: () {
              context.pushNamed('tools_weather');
            },
          ),
          _buildToolCard(
            context,
            title: 'Chat Bot',
            icon: Icons.chat_bubble_outline,
            color: Colors.blue,
            onTap: () => _showComingSoon(context, 'Chat Bot'),
          ),
          _buildToolCard(
            context,
            title: 'Konversi Waktu',
            icon: Icons.access_time,
            color: Colors.purple,
            onTap: () => _showComingSoon(context, 'Konversi Waktu'),
          ),
          _buildToolCard(
            context,
            title: 'Mata Uang',
            icon: Icons.currency_exchange,
            color: Colors.green,
            onTap: () => _showComingSoon(context, 'Mata Uang'),
          ),
          _buildToolCard(
            context,
            title: 'Game',
            icon: Icons.sports_esports_outlined,
            color: Colors.redAccent,
            onTap: () => _showComingSoon(context, 'Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $feature akan segera hadir!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
