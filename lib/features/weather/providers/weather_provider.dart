import 'package:flutter/foundation.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../domain/usecases/weather/get_weather_by_city_usecase.dart';
import '../../../domain/usecases/weather/get_weather_by_location_usecase.dart';

class WeatherProvider extends ChangeNotifier {
  final GetWeatherByLocationUseCase getWeatherByLocationUseCase;
  final GetWeatherByCityUseCase getWeatherByCityUseCase;
  final LocationService locationService;

  WeatherProvider({
    required this.getWeatherByLocationUseCase,
    required this.getWeatherByCityUseCase,
    required this.locationService,
  });

  WeatherEntity? _currentWeather;
  WeatherEntity? get currentWeather => _currentWeather;

  WeatherEntity? _cityWeather;
  WeatherEntity? get cityWeather => _cityWeather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCityLoading = false;
  bool get isCityLoading => _isCityLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _cityErrorMessage;
  String? get cityErrorMessage => _cityErrorMessage;

  Future<void> fetchCurrentLocationWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await locationService.getCurrentPosition();
      _currentWeather = await getWeatherByLocationUseCase(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    _isCityLoading = true;
    _cityErrorMessage = null;
    notifyListeners();

    try {
      _cityWeather = await getWeatherByCityUseCase(cityName);
    } catch (e) {
      _cityErrorMessage = e.toString().replaceAll('Exception: ', '');
      _cityWeather = null;
    } finally {
      _isCityLoading = false;
      notifyListeners();
    }
  }
}
