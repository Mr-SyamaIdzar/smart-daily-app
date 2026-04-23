import '../../repositories/weather_repository.dart';
import '../../entities/weather_entity.dart';

class GetWeatherByLocationUseCase {
  final WeatherRepository repository;

  GetWeatherByLocationUseCase(this.repository);

  Future<WeatherEntity> call(double lat, double lon) {
    return repository.getWeatherByLocation(lat, lon);
  }
}
