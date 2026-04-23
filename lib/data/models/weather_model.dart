import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    super.province,
    required super.temperature,
    required super.condition,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {String? provinceName}) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      province: provinceName,
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}
