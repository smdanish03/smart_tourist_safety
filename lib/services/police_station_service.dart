import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/police_station.dart';
import 'location_service.dart';

class NearbyPoliceStation {
  final PoliceStation station;
  final double distanceKm;

  const NearbyPoliceStation({
    required this.station,
    required this.distanceKm,
  });
}

class PoliceStationService {
  final LocationService _locationService =
      LocationService();

  Future<List<NearbyPoliceStation>>
      getNearbyPoliceStations({
    double radiusKm = 10,
  }) async {
    final LocationData location =
        await _locationService.getCurrentLocation();

    final double radiusMeters = radiusKm * 1000;

    final String query = '''
[out:json][timeout:30];
(
  node["amenity"="police"](around:$radiusMeters,${location.latitude},${location.longitude});
  way["amenity"="police"](around:$radiusMeters,${location.latitude},${location.longitude});
  relation["amenity"="police"](around:$radiusMeters,${location.latitude},${location.longitude});
);
out center tags;
''';

    final List<String> endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    http.Response? successfulResponse;

    for (final String endpoint in endpoints) {
      try {
        final Uri url = Uri.parse(endpoint);

        final http.Response response =
            await http
                .post(
                  url,
                  headers: {
                    'Content-Type':
                        'application/x-www-form-urlencoded',
                    'Accept': 'application/json',
                  },
                  body: {
                    'data': query,
                  },
                )
                .timeout(
                  const Duration(seconds: 35),
                );

        if (response.statusCode == 200 &&
            response.body.isNotEmpty) {
          successfulResponse = response;
          break;
        }
      } catch (_) {
        // Try the next Overpass server.
      }
    }

    if (successfulResponse == null) {
      throw Exception(
        'Nearby police stations could not be loaded. '
        'Please check your internet connection and try again.',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(
      successfulResponse.body,
    ) as Map<String, dynamic>;

    final List<dynamic> elements =
        (data['elements'] as List<dynamic>?) ?? [];

    final List<NearbyPoliceStation> stations = [];

    for (final dynamic element in elements) {
      if (element is! Map<String, dynamic>) {
        continue;
      }

      final Map<String, dynamic> item = element;

      final Map<String, dynamic> tags =
          item['tags'] is Map
              ? Map<String, dynamic>.from(
                  item['tags'] as Map,
                )
              : <String, dynamic>{};

      final double? latitude =
          _getLatitude(item);

      final double? longitude =
          _getLongitude(item);

      if (latitude == null ||
          longitude == null) {
        continue;
      }

      final String name =
          (tags['name'] ??
                  tags['name:en'] ??
                  tags['official_name'] ??
                  'Police Station')
              .toString()
              .trim();

      final String address =
          _buildAddress(tags);

      final String? phone =
          _getPhone(tags);

      final double distance =
          _calculateDistance(
        location.latitude,
        location.longitude,
        latitude,
        longitude,
      );

      stations.add(
        NearbyPoliceStation(
          station: PoliceStation(
            name: name,
            latitude: latitude,
            longitude: longitude,
            address: address,
            phone: phone,
          ),
          distanceKm: distance,
        ),
      );
    }

    stations.sort(
      (a, b) =>
          a.distanceKm.compareTo(b.distanceKm),
    );

    return _removeDuplicates(stations);
  }

  double? _getLatitude(
    Map<String, dynamic> item,
  ) {
    final dynamic lat = item['lat'];

    if (lat != null) {
      return double.tryParse(
        lat.toString(),
      );
    }

    final dynamic centerData = item['center'];

    if (centerData is! Map) {
      return null;
    }

    final dynamic centerLat =
        centerData['lat'];

    if (centerLat == null) {
      return null;
    }

    return double.tryParse(
      centerLat.toString(),
    );
  }

  double? _getLongitude(
    Map<String, dynamic> item,
  ) {
    final dynamic lon = item['lon'];

    if (lon != null) {
      return double.tryParse(
        lon.toString(),
      );
    }

    final dynamic centerData = item['center'];

    if (centerData is! Map) {
      return null;
    }

    final dynamic centerLon =
        centerData['lon'];

    if (centerLon == null) {
      return null;
    }

    return double.tryParse(
      centerLon.toString(),
    );
  }

  String _buildAddress(
    Map<String, dynamic> tags,
  ) {
    final List<String> parts = [];

    final List<String> keys = [
      'addr:housenumber',
      'addr:street',
      'addr:suburb',
      'addr:city',
      'addr:postcode',
    ];

    for (final String key in keys) {
      final dynamic value = tags[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        parts.add(
          value.toString().trim(),
        );
      }
    }

    if (parts.isEmpty) {
      return 'Address not available';
    }

    return parts.join(', ');
  }

  String? _getPhone(
    Map<String, dynamic> tags,
  ) {
    final dynamic phone =
        tags['phone'] ??
        tags['contact:phone'] ??
        tags['contact:mobile'];

    if (phone == null) {
      return null;
    }

    final String value =
        phone.toString().trim();

    return value.isEmpty ? null : value;
  }

  List<NearbyPoliceStation>
      _removeDuplicates(
    List<NearbyPoliceStation> stations,
  ) {
    final Set<String> seen = {};
    final List<NearbyPoliceStation> result = [];

    for (final NearbyPoliceStation nearby
        in stations) {
      final String key =
          '${nearby.station.name.toLowerCase()}|'
          '${nearby.station.latitude.toStringAsFixed(5)}|'
          '${nearby.station.longitude.toStringAsFixed(5)}';

      if (seen.add(key)) {
        result.add(nearby);
      }
    }

    return result;
  }

  double _calculateDistance(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const double earthRadiusKm = 6371;

    final double lat1 =
        _degreesToRadians(latitude1);

    final double lat2 =
        _degreesToRadians(latitude2);

    final double differenceLatitude =
        _degreesToRadians(
      latitude2 - latitude1,
    );

    final double differenceLongitude =
        _degreesToRadians(
      longitude2 - longitude1,
    );

    final double a =
        sin(differenceLatitude / 2) *
                sin(differenceLatitude / 2) +
            cos(lat1) *
                cos(lat2) *
                sin(differenceLongitude / 2) *
                sin(differenceLongitude / 2);

    final double c =
        2 *
        atan2(
          sqrt(a),
          sqrt(1 - a),
        );

    return earthRadiusKm * c;
  }

  double _degreesToRadians(
    double degrees,
  ) {
    return degrees * pi / 180;
  }
}