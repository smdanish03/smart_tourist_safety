import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/tourist_places.dart';
import '../models/tourist_place.dart';
import 'location_service.dart';
import 'notification_service.dart';

class GeofenceZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const GeofenceZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}

class GeofenceResult {
  final GeofenceZone zone;
  final double distanceMeters;
  final bool isInside;

  const GeofenceResult({
    required this.zone,
    required this.distanceMeters,
    required this.isInside,
  });
}

class GeofenceService {
  final LocationService _locationService = LocationService();

  // Prevents repeated notifications for the same
  // tourist zone during the current app session.
  static final Set<String> _notifiedZoneIds = <String>{};

  // ------------------------------------------------------------
  // CHECK ALL TOURIST ZONES
  // ------------------------------------------------------------

  Future<List<GeofenceResult>> checkZones(
    List<GeofenceZone> zones,
  ) async {
    final LocationData currentLocation =
        await _locationService.getCurrentLocation();

    final List<GeofenceResult> results = <GeofenceResult>[];

    for (final GeofenceZone zone in zones) {
      final double distanceMeters = _calculateDistanceMeters(
        currentLocation.latitude,
        currentLocation.longitude,
        zone.latitude,
        zone.longitude,
      );

      final bool isInside = distanceMeters <= zone.radiusMeters;

      final GeofenceResult result = GeofenceResult(
        zone: zone,
        distanceMeters: distanceMeters,
        isInside: isInside,
      );

      results.add(result);

      // Notification must never block the actual
      // geofence calculation.
      if (isInside) {
        _sendGeoFenceNotificationSafely(zone);
      }
    }

    return results;
  }

  // ------------------------------------------------------------
  // SAFE GEOFENCE NOTIFICATION
  // ------------------------------------------------------------

  void _sendGeoFenceNotificationSafely(
    GeofenceZone zone,
  ) {
    // Local notifications are not supported by our
    // Android notification implementation on Flutter Web.
    if (kIsWeb) {
      return;
    }

    if (_notifiedZoneIds.contains(zone.id)) {
      return;
    }

    // Mark it immediately so repeated calls during
    // the same session do not create duplicates.
    _notifiedZoneIds.add(zone.id);

    _showNotification(zone);
  }

  Future<void> _showNotification(
    GeofenceZone zone,
  ) async {
    try {
      await NotificationService.showGeoFenceNotification(
        placeName: zone.name,
      );
    } catch (_) {
      // Notification failure must never break
      // the geofencing feature.
    }
  }

  // ------------------------------------------------------------
  // CREATE TOURIST ZONES
  // ------------------------------------------------------------

  List<GeofenceZone> createTouristZones({
    double radiusMeters = 500,
  }) {
    return touristPlaces.map(
      (TouristPlace place) {
        return GeofenceZone(
          id: place.name
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), '_')
              .replaceAll(RegExp(r'[^a-z0-9_]+'), ''),
          name: place.name,
          latitude: place.latitude,
          longitude: place.longitude,
          radiusMeters: radiusMeters,
        );
      },
    ).toList();
  }

  // ------------------------------------------------------------
  // DISTANCE CALCULATION
  // ------------------------------------------------------------

  double _calculateDistanceMeters(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const double earthRadiusMeters = 6371000;

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

    final double c = 2 * atan2(
      sqrt(a),
      sqrt(1 - a),
    );

    return earthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}