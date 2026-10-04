import 'dart:math';

import '../data/tourist_places.dart';
import '../models/tourist_place.dart';
import 'location_service.dart';

class NearbyTouristPlace {
  final TouristPlace place;
  final double distanceKm;

  const NearbyTouristPlace({
    required this.place,
    required this.distanceKm,
  });
}

class NearbyPlacesService {
  final LocationService _locationService = LocationService();

  Future<List<NearbyTouristPlace>> getNearbyPlaces({
    double radiusKm = 20,
  }) async {
    final LocationData currentLocation =
        await _locationService.getCurrentLocation();

    final List<NearbyTouristPlace> nearbyPlaces = [];

    for (final TouristPlace place in touristPlaces) {
      final double distance = _calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        place.latitude,
        place.longitude,
      );

      if (distance <= radiusKm) {
        nearbyPlaces.add(
          NearbyTouristPlace(
            place: place,
            distanceKm: distance,
          ),
        );
      }
    }

    nearbyPlaces.sort(
      (a, b) => a.distanceKm.compareTo(b.distanceKm),
    );

    return nearbyPlaces;
  }

  double _calculateDistance(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const double earthRadiusKm = 6371;

    final double lat1 = _degreesToRadians(latitude1);
    final double lat2 = _degreesToRadians(latitude2);

    final double differenceLatitude =
        _degreesToRadians(latitude2 - latitude1);

    final double differenceLongitude =
        _degreesToRadians(longitude2 - longitude1);

    final double a =
        sin(differenceLatitude / 2) *
                sin(differenceLatitude / 2) +
            cos(lat1) *
                cos(lat2) *
                sin(differenceLongitude / 2) *
                sin(differenceLongitude / 2);

    final double c =
        2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}