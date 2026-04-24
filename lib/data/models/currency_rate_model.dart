class CurrencyRate {
  final String baseCode;
  final Map<String, double> rates;
  final DateTime lastUpdate;

  CurrencyRate({
    required this.baseCode,
    required this.rates,
    required this.lastUpdate,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> conversionRates = json['conversion_rates'] ?? {};
    return CurrencyRate(
      baseCode: json['base_code'] ?? '',
      rates: conversionRates.map((key, value) => MapEntry(key, (value as num).toDouble())),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch((json['time_last_update_unix'] ?? 0) * 1000),
    );
  }
}
