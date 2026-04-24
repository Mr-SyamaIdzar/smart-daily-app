import '../datasources/remote/currency_api_service.dart';
import '../models/currency_rate_model.dart';

class CurrencyRepository {
  final CurrencyApiService _apiService;

  CurrencyRepository(this._apiService);

  Future<CurrencyRate> getLatestRates(String baseCurrency) {
    return _apiService.getLatestRates(baseCurrency);
  }
}
