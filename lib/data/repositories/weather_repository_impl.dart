import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/remote/weather_remote_ds.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeatherEntity> getWeatherByLocation(double lat, double lon) async {
    return await remoteDataSource.getWeatherByLocation(lat, lon);
  }

  @override
  Future<WeatherEntity> getWeatherByCity(String cityName) async {
    return await remoteDataSource.getWeatherByCity(cityName);
  }
}
