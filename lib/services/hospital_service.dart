
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/hospital.dart';
import 'location_service.dart';

class NearbyHospital {
  final Hospital hospital;
  final double distanceKm;

  const NearbyHospital({
    required this.hospital,
    required this.distanceKm,
  });
}

class HospitalService {
  final LocationService _locationService =
      LocationService();

static const List<String> _overpassEndpoints = [
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass-api.de/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
];

  Future<List<NearbyHospital>> getNearbyHospitals({
    double radiusKm = 15,
  }) async {
    final LocationData location =
        await _locationService.getCurrentLocation();

    final double radiusMeters = radiusKm * 1000;

    final String query = '''
[out:json][timeout:35];
(
  node["amenity"="hospital"](around:$radiusMeters,${location.latitude},${location.longitude});
  way["amenity"="hospital"](around:$radiusMeters,${location.latitude},${location.longitude});
  relation["amenity"="hospital"](around:$radiusMeters,${location.latitude},${location.longitude});

  node["healthcare"="hospital"](around:$radiusMeters,${location.latitude},${location.longitude});
  way["healthcare"="hospital"](around:$radiusMeters,${location.latitude},${location.longitude});
  relation["healthcare"="hospital"](around:$radiusMeters,${location.latitude},${location.longitude});
);
out center tags;
''';

    Exception? lastError;

    for (final String endpoint
        in _overpassEndpoints) {
      try {
        final List<NearbyHospital> hospitals =
            await _fetchFromOverpass(
          endpoint: endpoint,
          query: query,
          userLatitude: location.latitude,
          userLongitude: location.longitude,
        );

        hospitals.sort(
          (a, b) =>
              a.distanceKm.compareTo(
            b.distanceKm,
          ),
        );

        return _removeDuplicates(hospitals);
      } catch (error) {
        lastError = Exception(error);
      }
    }

    throw Exception(
      'Unable to load nearby hospitals. '
      'Please check your internet connection and try again.'
      '${lastError != null ? ' ${lastError.toString()}' : ''}',
    );
  }

  Future<List<NearbyHospital>>
      _fetchFromOverpass({
    required String endpoint,
    required String query,
    required double userLatitude,
    required double userLongitude,
  }) async {
    final Uri url = Uri.parse(endpoint);

    final http.Response response =
        await http
            .post(
              url,
           headers: const {
  'Content-Type':
      'application/x-www-form-urlencoded',
  'Accept': 'application/json',
  'User-Agent':
      'SmartTouristSafety/1.0',
},
              body: {
                'data': query,
              },
            )
            .timeout(
              const Duration(
                seconds: 40,
              ),
            );

    if (response.statusCode != 200) {
      throw Exception(
        'Hospital service returned HTTP '
        '${response.statusCode}.',
      );
    }

    if (response.body.trim().isEmpty) {
      throw Exception(
        'Hospital service returned empty data.',
      );
    }

    final dynamic decoded =
        jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid hospital service response.',
      );
    }

    final dynamic rawElements =
        decoded['elements'];

    if (rawElements is! List) {
      throw Exception(
        'Hospital data is unavailable.',
      );
    }

    final List<NearbyHospital> hospitals = [];

    for (final dynamic element
        in rawElements) {
      if (element is! Map) {
        continue;
      }

      final Map<String, dynamic> item =
          Map<String, dynamic>.from(element);

      final Map<String, dynamic> tags =
          _getTags(item);

      final double? latitude =
          _getLatitude(item);

      final double? longitude =
          _getLongitude(item);

      if (latitude == null ||
          longitude == null) {
        continue;
      }

      final String name =
          _getName(tags);

      final String address =
          _buildAddress(tags);

      final String? phone =
          _getPhone(tags);

      final bool? emergency =
          _getEmergency(tags);

      final double distance =
          _calculateDistance(
        userLatitude,
        userLongitude,
        latitude,
        longitude,
      );

      hospitals.add(
        NearbyHospital(
          hospital: Hospital(
            name: name,
            latitude: latitude,
            longitude: longitude,
            address: address,
            phone: phone,
            emergency: emergency,
          ),
          distanceKm: distance,
        ),
      );
    }

    return hospitals;
  }

  Map<String, dynamic> _getTags(
    Map<String, dynamic> item,
  ) {
    final dynamic rawTags =
        item['tags'];

    if (rawTags is Map) {
      return Map<String, dynamic>.from(
        rawTags,
      );
    }

    return {};
  }

  double? _getLatitude(
    Map<String, dynamic> item,
  ) {
    final dynamic lat =
        item['lat'];

    if (lat != null) {
      return double.tryParse(
        lat.toString(),
      );
    }

    final dynamic centerData =
        item['center'];

    if (centerData is Map) {
      final dynamic centerLat =
          centerData['lat'];

      if (centerLat != null) {
        return double.tryParse(
          centerLat.toString(),
        );
      }
    }

    return null;
  }

  double? _getLongitude(
    Map<String, dynamic> item,
  ) {
    final dynamic lon =
        item['lon'];

    if (lon != null) {
      return double.tryParse(
        lon.toString(),
      );
    }

    final dynamic centerData =
        item['center'];

    if (centerData is Map) {
      final dynamic centerLon =
          centerData['lon'];

      if (centerLon != null) {
        return double.tryParse(
          centerLon.toString(),
        );
      }
    }

    return null;
  }

  String _getName(
    Map<String, dynamic> tags,
  ) {
    final List<String> possibleNames = [
      'name',
      'name:en',
      'official_name',
      'short_name',
    ];

    for (final String key
        in possibleNames) {
      final dynamic value =
          tags[key];

      if (value != null) {
        final String name =
            value.toString().trim();

        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return 'Hospital';
  }

  String _buildAddress(
    Map<String, dynamic> tags,
  ) {
    final List<String> parts = [];

    final List<String> keys = [
      'addr:housenumber',
      'addr:street',
      'addr:place',
      'addr:suburb',
      'addr:district',
      'addr:city',
      'addr:postcode',
    ];

    for (final String key in keys) {
      final dynamic value =
          tags[key];

      if (value != null) {
        final String text =
            value.toString().trim();

        if (text.isNotEmpty) {
          parts.add(text);
        }
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
        tags['contact_phone'] ??
        tags['telephone'];

    if (phone == null) {
      return null;
    }

    final String value =
        phone.toString().trim();

    return value.isEmpty
        ? null
        : value;
  }

  bool? _getEmergency(
    Map<String, dynamic> tags,
  ) {
    final dynamic value =
        tags['emergency'];

    if (value == null) {
      return null;
    }

    final String emergency =
        value
            .toString()
            .toLowerCase()
            .trim();

    if (emergency == 'yes' ||
        emergency == 'true') {
      return true;
    }

    if (emergency == 'no' ||
        emergency == 'false') {
      return false;
    }

    return null;
  }

  List<NearbyHospital>
      _removeDuplicates(
    List<NearbyHospital> hospitals,
  ) {
    final Set<String> seen = {};
    final List<NearbyHospital> result = [];

    for (final NearbyHospital nearby
        in hospitals) {
      final String key =
          '${nearby.hospital.name.toLowerCase()}|'
          '${nearby.hospital.latitude.toStringAsFixed(5)}|'
          '${nearby.hospital.longitude.toStringAsFixed(5)}';

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
    const double earthRadiusKm =
        6371.0;

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
        sin(
              differenceLatitude / 2,
            ) *
            sin(
              differenceLatitude / 2,
            ) +
        cos(lat1) *
            cos(lat2) *
            sin(
              differenceLongitude / 2,
            ) *
            sin(
              differenceLongitude / 2,
            );

    final double c =
        2 *
            atan2(
              sqrt(a),
              sqrt(
                1 - a,
              ),
            );

    return earthRadiusKm * c;
  }

  double _degreesToRadians(
    double degrees,
  ) {
    return degrees * pi / 180;
  }
}
