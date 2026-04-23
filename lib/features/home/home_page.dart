import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../auth/providers/auth_provider.dart';
import '../weather/providers/weather_provider.dart';

/// Halaman Home (Dashboard) Aplikasi
class HomePage extends StatefulWidget {
  final void Function(int index)? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = context.read<WeatherProvider>();
      if (weatherProvider.currentWeather == null) {
        weatherProvider.fetchCurrentLocationWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: AppSizes.xl),
              _buildWeatherCard(),
              const SizedBox(height: AppSizes.xl),
              _buildShortcuts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Halo,',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${user?.fullName ?? 'Pengguna'} 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => widget.onNavigateTab?.call(3), // Index 3 is Profile
          child: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryLight.withOpacity(0.15),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.currentWeather;
    final isLoading = weatherProvider.isLoading;
    final errorMessage = weatherProvider.errorMessage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat cuaca\n$errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => weatherProvider.fetchCurrentLocationWeather(),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weather?.cityName ?? 'Mencari lokasi...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (weather?.province != null && weather!.province!.isNotEmpty)
                                      Text(
                                        weather.province!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.75),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            weather != null ? '${weather.temperature.round()}°C' : '--°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather?.condition ?? '--',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (weather != null)
                      Image.network(
                        weather.iconUrl,
                        width: 72,
                        height: 72,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cloud_queue_rounded,
                          color: Colors.white,
                          size: 72,
                        ),
                      )
                    else
                      const Icon(
                        Icons.cloud_queue_rounded,
                        color: Colors.white,
                        size: 72,
                      ),
                  ],
                ),
    );
  }

  Widget _buildShortcuts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _ShortcutCard(
                icon: Icons.note_alt_rounded,
                title: 'Catatan',
                subtitle: 'Tulis idemu',
                color: AppColors.info,
                onTap: () {
                  widget.onNavigateTab?.call(1); // Index 1 is Notes
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _ShortcutCard(
                icon: Icons.handyman_rounded,
                title: 'Tools',
                subtitle: 'Alat bantu',
                color: AppColors.success,
                onTap: () {
                  widget.onNavigateTab?.call(2); // Index 2 is Tools
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

