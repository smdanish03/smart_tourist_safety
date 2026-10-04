import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

class WeatherService {
  Future<WeatherData> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final Uri url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current='
          'temperature_2m,'
          'relative_humidity_2m,'
          'apparent_temperature,'
          'wind_speed_10m,'
          'weather_code'
      '&timezone=auto',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Weather API failed: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final Map<String, dynamic> current =
          data['current'] as Map<String, dynamic>;

      final double temperature =
          (current['temperature_2m'] as num).toDouble();

      final double feelsLike =
          (current['apparent_temperature'] as num).toDouble();

      final int humidity =
          (current['relative_humidity_2m'] as num).toInt();

      final double windSpeed =
          (current['wind_speed_10m'] as num).toDouble();

      final int weatherCode =
          (current['weather_code'] as num).toInt();

      return WeatherData(
        temperature: temperature,
        feelsLike: feelsLike,
        humidity: humidity,
        windSpeed: windSpeed,
        description: _getWeatherDescription(weatherCode),
        icon: _getWeatherIcon(weatherCode),
      );
    } catch (e) {
      throw Exception('Unable to load weather: $e');
    }
  }

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';

      case 1:
        return 'Mainly clear';

      case 2:
        return 'Partly cloudy';

      case 3:
        return 'Overcast';

      case 45:
      case 48:
        return 'Foggy';

      case 51:
      case 53:
      case 55:
        return 'Drizzle';

      case 56:
      case 57:
        return 'Freezing drizzle';

      case 61:
      case 63:
      case 65:
        return 'Rain';

      case 66:
      case 67:
        return 'Freezing rain';

      case 71:
      case 73:
      case 75:
      case 77:
        return 'Snow';

      case 80:
      case 81:
      case 82:
        return 'Rain showers';

      case 85:
      case 86:
        return 'Snow showers';

      case 95:
        return 'Thunderstorm';

      case 96:
      case 99:
        return 'Thunderstorm with hail';

      default:
        return 'Unknown weather';
    }
  }

  String _getWeatherIcon(int code) {
    if (code == 0) {
      return '☀️';
    }

    if (code == 1 || code == 2) {
      return '🌤️';
    }

    if (code == 3) {
      return '☁️';
    }

    if (code == 45 || code == 48) {
      return '🌫️';
    }

    if (code >= 51 && code <= 57) {
      return '🌦️';
    }

    if (code >= 61 && code <= 67) {
      return '🌧️';
    }

    if (code >= 71 && code <= 77) {
      return '❄️';
    }

    if (code >= 80 && code <= 82) {
      return '🌦️';
    }

    if (code >= 85 && code <= 86) {
      return '🌨️';
    }

    if (code >= 95 && code <= 99) {
      return '⛈️';
    }

    return '🌤️';
  }
}