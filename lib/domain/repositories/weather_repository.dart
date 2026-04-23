import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getWeatherByLocation(double lat, double lon);
  Future<WeatherEntity> getWeatherByCity(String cityName);
}
