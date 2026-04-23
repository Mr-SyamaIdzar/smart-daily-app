import '../../repositories/weather_repository.dart';
import '../../entities/weather_entity.dart';

class GetWeatherByCityUseCase {
  final WeatherRepository repository;

  GetWeatherByCityUseCase(this.repository);

  Future<WeatherEntity> call(String cityName) {
    return repository.getWeatherByCity(cityName);
  }
}
