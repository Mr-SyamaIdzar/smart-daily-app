import 'package:flutter/material.dart';
import '../../../data/repositories/currency_repository.dart';
import '../../../data/models/currency_rate_model.dart';

class CurrencyProvider with ChangeNotifier {
  final CurrencyRepository _repository;

  CurrencyProvider(this._repository);

  CurrencyRate? _currentRates;
  bool _isLoading = false;
  String? _errorMessage;

  CurrencyRate? get currentRates => _currentRates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // State for conversion
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  double _amount = 1.0;
  double _result = 0.0;

  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  double get amount => _amount;
  double get result => _result;

  set fromCurrency(String value) {
    _fromCurrency = value;
    calculateConversion();
    notifyListeners();
  }

  set toCurrency(String value) {
    _toCurrency = value;
    calculateConversion();
    notifyListeners();
  }

  set amount(double value) {
    _amount = value;
    calculateConversion();
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    fetchRates();
  }

  Future<void> fetchRates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentRates = await _repository.getLatestRates(_fromCurrency);
      calculateConversion();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void calculateConversion() {
    if (_currentRates != null && _currentRates!.rates.containsKey(_toCurrency)) {
      final rate = _currentRates!.rates[_toCurrency]!;
      _result = _amount * rate;
    }
  }

  // Mock data for chart (since free API doesn't provide historical)
  // In a real app, you'd fetch this from a historical API endpoint
  List<double> getTrendData() {
    // Returning some random-looking but stable trends for the UI demo
    if (_fromCurrency == 'USD' && _toCurrency == 'IDR') {
      return [15500, 15600, 15550, 15700, 15800, 15750, 15850];
    } else if (_fromCurrency == 'IDR' && _toCurrency == 'USD') {
      return [0.000064, 0.000063, 0.000064, 0.000063, 0.000062, 0.000063, 0.000062];
    } else {
      return [1.0, 1.02, 0.98, 1.05, 1.1, 1.08, 1.15];
    }
  }
}
