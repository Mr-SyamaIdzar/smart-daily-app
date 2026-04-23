class WeatherEntity {
  final String cityName;
  final String? province;
  final double temperature;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  const WeatherEntity({
    required this.cityName,
    this.province,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
