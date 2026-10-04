import '../models/weather_data.dart';
import 'location_service.dart';
import 'weather_service.dart';

class LocationWeatherData {
  final LocationData location;
  final WeatherData weather;

  const LocationWeatherData({
    required this.location,
    required this.weather,
  });
}

class LocationWeatherService {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  Future<LocationWeatherData> getLocationAndWeather() async {
    final LocationData location =
        await _locationService.getCurrentLocation();

    final WeatherData weather =
        await _weatherService.getWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );

    return LocationWeatherData(
      location: location,
      weather: weather,
    );
  }
}