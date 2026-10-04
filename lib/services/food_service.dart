import 'dart:convert';

import 'package:http/http.dart' as http;

class FoodPlace {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String cuisine;
  final String phone;
  final String website;

  const FoodPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.cuisine,
    required this.phone,
    required this.website,
  });

  String get displayType {
    switch (type) {
      case 'cafe':
        return 'Cafe';
      case 'fast_food':
        return 'Fast Food';
      case 'food_court':
        return 'Food Court';
      default:
        return 'Restaurant';
    }
  }
}

class FoodService {
  static const String _overpassUrl =
      'https://overpass-api.de/api/interpreter';

  Future<List<FoodPlace>> getNearbyFood({
    required double latitude,
    required double longitude,
    double radiusMeters = 3000,
  }) async {
    final String query = '''
[out:json][timeout:25];
(
  nwr["amenity"="restaurant"](around:$radiusMeters,$latitude,$longitude);
  nwr["amenity"="cafe"](around:$radiusMeters,$latitude,$longitude);
  nwr["amenity"="fast_food"](around:$radiusMeters,$latitude,$longitude);
  nwr["amenity"="food_court"](around:$radiusMeters,$latitude,$longitude);
);
out center tags;
''';

    final Uri uri = Uri.parse(_overpassUrl).replace(
      queryParameters: <String, String>{
        'data': query,
      },
    );

    final http.Response response = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load nearby food places. '
        'Server returned ${response.statusCode}.',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid food data received.');
    }

    final dynamic elements = decoded['elements'];

    if (elements is! List) {
      return <FoodPlace>[];
    }

    final List<FoodPlace> places = [];

    for (final dynamic item in elements) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final dynamic tagsValue = item['tags'];

      if (tagsValue is! Map) {
        continue;
      }

      final Map<String, dynamic> tags =
          Map<String, dynamic>.from(tagsValue);

      final String name =
          (tags['name']?.toString() ?? '').trim();

      if (name.isEmpty) {
        continue;
      }

      double? placeLatitude;
      double? placeLongitude;

      if (item['lat'] is num && item['lon'] is num) {
        placeLatitude = (item['lat'] as num).toDouble();
        placeLongitude = (item['lon'] as num).toDouble();
      } else {
        final dynamic center = item['center'];

        if (center is Map) {
          if (center['lat'] is num && center['lon'] is num) {
            placeLatitude =
                (center['lat'] as num).toDouble();
            placeLongitude =
                (center['lon'] as num).toDouble();
          }
        }
      }

      if (placeLatitude == null ||
          placeLongitude == null) {
        continue;
      }

      String type = 'restaurant';

      if (tags['amenity'] != null) {
        type = tags['amenity'].toString();
      }

      final String address = _buildAddress(tags);

      final String cuisine =
          (tags['cuisine']?.toString() ?? '').trim();

      final String phone =
          (tags['phone']?.toString() ??
                  tags['contact:phone']?.toString() ??
                  '')
              .trim();

      final String website =
          (tags['website']?.toString() ??
                  tags['contact:website']?.toString() ??
                  '')
              .trim();

      places.add(
        FoodPlace(
          id: item['id']?.toString() ??
              '${placeLatitude}_$placeLongitude',
          name: name,
          type: type,
          latitude: placeLatitude,
          longitude: placeLongitude,
          address: address,
          cuisine: cuisine,
          phone: phone,
          website: website,
        ),
      );
    }

    final Map<String, FoodPlace> uniquePlaces =
        <String, FoodPlace>{};

    for (final FoodPlace place in places) {
      final String key =
          '${place.name.toLowerCase()}_${place.latitude.toStringAsFixed(5)}_${place.longitude.toStringAsFixed(5)}';

      uniquePlaces[key] = place;
    }

    return uniquePlaces.values.toList();
  }

  String _buildAddress(
    Map<String, dynamic> tags,
  ) {
    final List<String> parts = <String>[];

    final List<String?> possibleParts = <String?>[
      tags['addr:housenumber']?.toString(),
      tags['addr:street']?.toString(),
      tags['addr:suburb']?.toString(),
      tags['addr:city']?.toString(),
    ];

    for (final String? part in possibleParts) {
      if (part != null && part.trim().isNotEmpty) {
        parts.add(part.trim());
      }
    }

    if (parts.isEmpty) {
      return 'Address not available';
    }

    return parts.join(', ');
  }
}