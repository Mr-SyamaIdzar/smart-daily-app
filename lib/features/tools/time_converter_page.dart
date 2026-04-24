import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/time_converter_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class TimeConverterPage extends StatelessWidget {
  const TimeConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Converter'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<TimeConverterProvider>(
        builder: (context, provider, child) {
          final conversions = provider.getConvertedTimes();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSourceCard(context, provider),
                const SizedBox(height: AppSizes.lg),
                const Text(
                  'Hasil Konversi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                ...conversions.entries.map((entry) => _buildResultCard(entry.key, entry.value)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context, TimeConverterProvider provider) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: provider.selectedZone,
              decoration: const InputDecoration(
                labelText: 'Zona Waktu Asal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              items: provider.timezones.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) provider.selectedZone = newValue;
              },
            ),
            const SizedBox(height: AppSizes.lg),
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: provider.selectedTime,
                );
                if (picked != null) provider.selectedTime = picked;
              },
              child: Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: AppColors.primary, size: 32),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      provider.selectedTime.format(context),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Ketuk angka di atas untuk mengubah waktu',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String zone, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            zone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
