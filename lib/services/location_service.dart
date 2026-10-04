import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String placeName;
  final String city;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.city,
  });
}

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    // 1. Check whether location service is enabled.
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location service is disabled. Please enable GPS/location.',
      );
    }

    // 2. Check location permission.
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. Ask user for permission if not already granted.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 4. Permission permanently denied.
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it from device settings.',
      );
    }

    // 5. Permission still denied.
    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission was denied.',
      );
    }

    // 6. Get current GPS position.
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // 7. Convert coordinates into a readable place name.
    final String placeName = await _getPlaceName(
      position.latitude,
      position.longitude,
    );

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      placeName: placeName,
      city: 'Mumbai',
    );
  }

  Future<String> _getPlaceName(
    double latitude,
    double longitude,
  ) async {
    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=jsonv2'
      '&lat=$latitude'
      '&lon=$longitude'
      '&zoom=18'
      '&addressdetails=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SmartTouristSafety/1.0',
        },
      ).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode != 200) {
        return 'Mumbai';
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final Map<String, dynamic> address =
          (data['address'] as Map<String, dynamic>?) ?? {};

      // Try to find the most useful local area name.
      final List<String?> possibleNames = [
        address['neighbourhood'] as String?,
        address['suburb'] as String?,
        address['quarter'] as String?,
        address['city_district'] as String?,
        address['town'] as String?,
        address['village'] as String?,
      ];

      for (final String? name in possibleNames) {
        if (name != null && name.trim().isNotEmpty) {
          return name.trim();
        }
      }

      // Fallback to city.
      final String? city = address['city'] as String?;

      if (city != null && city.trim().isNotEmpty) {
        return city.trim();
      }

      return 'Mumbai';
    } catch (_) {
      return 'Mumbai';
    }
  }
}