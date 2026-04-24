import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/currency_rate_model.dart';

class CurrencyApiService {
  final Dio _dio;
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  CurrencyApiService(this._dio);

  Future<CurrencyRate> getLatestRates(String baseCurrency) async {
    final apiKey = dotenv.get('EXCHANGERATE_API_KEY');
    try {
      final response = await _dio.get('$_baseUrl/$apiKey/latest/$baseCurrency');
      
      if (response.statusCode == 200) {
        return CurrencyRate.fromJson(response.data);
      } else {
        throw Exception('Failed to load currency rates');
      }
    } catch (e) {
      throw Exception('Error fetching currency rates: $e');
    }
  }
}
