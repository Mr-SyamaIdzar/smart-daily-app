import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherByLocation(double lat, double lon);
  Future<WeatherModel> getWeatherByCity(String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  WeatherRemoteDataSourceImpl({required this.client});

  @override
  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    // 1. Dapatkan nama provinsi/state via Reverse Geocoding API
    String? provinceName;
    try {
      final geoUrl = Uri.parse('http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$_apiKey');
      final geoResponse = await client.get(geoUrl);
      if (geoResponse.statusCode == 200) {
        final List geoData = json.decode(geoResponse.body);
        if (geoData.isNotEmpty) {
          provinceName = geoData[0]['state'];
        }
      }
    } catch (e) {
      // Abaikan jika geo gagal, tetap ambil cuaca utamanya
    }

    // 2. Dapatkan data cuaca utama
    final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body), provinceName: provinceName);
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }

  @override
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    // 1. Dapatkan koordinat dan provinsi dari Direct Geocoding API
    // Ini mendukung pencarian spesifik seperti "Depok, Sleman"
    double? lat;
    double? lon;
    String? provinceName;

    final geoUrl = Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$_apiKey');
    final geoResponse = await client.get(geoUrl);

    if (geoResponse.statusCode == 200) {
      final List geoData = json.decode(geoResponse.body);
      if (geoData.isNotEmpty) {
        lat = geoData[0]['lat'];
        lon = geoData[0]['lon'];
        provinceName = geoData[0]['state'];
      } else {
        throw Exception('Kota tidak ditemukan');
      }
    } else {
      throw Exception('Gagal mencari kota');
    }

    // 2. Gunakan koordinat tersebut untuk memanggil Weather API
    final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body), provinceName: provinceName);
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }
}
