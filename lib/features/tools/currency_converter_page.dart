import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'providers/currency_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CurrencyProvider>().fetchRates();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConversionCard(provider),
                const SizedBox(height: AppSizes.lg),
                _buildTrendSection(provider),
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.md),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversionCard(CurrencyProvider provider) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixIcon: Icon(Icons.calculate_outlined),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                provider.amount = amount;
              },
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(child: _buildCurrencyDropdown(provider, true)),
                IconButton(
                  onPressed: provider.swapCurrencies,
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  tooltip: 'Tukar Mata Uang',
                ),
                Expanded(child: _buildCurrencyDropdown(provider, false)),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Text(
                          '${provider.amount} ${provider.fromCurrency} =',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(provider.result)} ${provider.toCurrency}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(CurrencyProvider provider, bool isFrom) {
    const currencies = ['USD', 'IDR', 'EUR', 'GBP', 'JPY', 'SGD'];
    return DropdownButtonFormField<String>(
      value: isFrom ? provider.fromCurrency : provider.toCurrency,
      decoration: InputDecoration(
        labelText: isFrom ? 'Dari' : 'Ke',
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 0),
        border: const OutlineInputBorder(),
      ),
      items: currencies.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          if (isFrom) {
            provider.fromCurrency = newValue;
            provider.fetchRates();
          } else {
            provider.toCurrency = newValue;
          }
        }
      },
    );
  }

  Widget _buildTrendSection(CurrencyProvider provider) {
    final trendData = provider.getTrendData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tren Nilai Mata Uang (7 Hari Terakhir)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: trendData.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const Text(
          '* Data tren adalah simulasi untuk demonstrasi UI.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
