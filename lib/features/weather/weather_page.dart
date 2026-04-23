import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import 'providers/weather_provider.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.cityWeather;
    final isLoading = weatherProvider.isCityLoading;
    final error = weatherProvider.cityErrorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Cuaca Kota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cari tahu kondisi cuaca seketika di kota mana pun di seluruh dunia.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),
            
            // Search Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Nama Kota (mis: Bandung)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) => _searchCity(),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                ElevatedButton(
                  onPressed: isLoading ? null : _searchCity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    minimumSize: const Size(56, 56), // Override global double.infinity
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search),
                ),
              ],
            ),
            
            // Error Message
            if (error != null) ...[
              const SizedBox(height: AppSizes.lg),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Text(
                        error,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Weather Result Card
            if (weather != null && !isLoading && error == null) ...[
              const SizedBox(height: AppSizes.xl),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  side: const BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.radiusLg),
                          topRight: Radius.circular(AppSizes.radiusLg),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather.cityName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (weather.province != null && weather.province!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    weather.province!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  weather.condition,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.network(
                            weather.iconUrl,
                            width: 80,
                            height: 80,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.cloud_queue_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail(
                            icon: Icons.thermostat,
                            label: 'Temperatur',
                            value: '${weather.temperature.round()} Celcius',
                          ),
                          _buildWeatherDetail(
                            icon: Icons.water_drop_outlined,
                            label: 'Kelembapan',
                            value: '${weather.humidity}%',
                          ),
                          _buildWeatherDetail(
                            icon: Icons.air,
                            label: 'Angin',
                            value: '${weather.windSpeed} m/s',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: AppSizes.sm),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _searchCity() {
    FocusScope.of(context).unfocus();
    final city = _cityController.text;
    if (city.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeatherByCity(city);
    }
  }
}
