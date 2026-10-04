import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/tourist_places.dart';
import '../../models/tourist_place.dart';
import '../../services/location_service.dart';
import 'place_details_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LocationData? _location;
  bool _isLoading = true;
  String? _errorMessage;

  static const LatLng _mumbaiCenter = LatLng(
    19.0760,
    72.8777,
  );

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final LocationData location =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _location = location;
        _isLoading = false;
      });

      _mapController.move(
        LatLng(
          location.latitude,
          location.longitude,
        ),
        15,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _goToCurrentLocation() {
    if (_location == null) return;

    _mapController.move(
      LatLng(
        _location!.latitude,
        _location!.longitude,
      ),
      16,
    );
  }

  void _showPlaceDetails(TouristPlace place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailsPage(
          place: place,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialCenter = _location == null
        ? _mumbaiCenter
        : LatLng(
            _location!.latitude,
            _location!.longitude,
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Explore Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadLocation,
            tooltip: 'Refresh location',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.smart_tourist_safety',
              ),

              // Tourist place markers
              MarkerLayer(
                markers: touristPlaces.map(
                  (place) {
                    return Marker(
                      point: LatLng(
                        place.latitude,
                        place.longitude,
                      ),
                      width: 55,
                      height: 55,
                      child: GestureDetector(
                        onTap: () {
                          _showPlaceDetails(place);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.18),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),

              // Current location marker
              if (_location != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _location!.latitude,
                        _location!.longitude,
                      ),
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue
                                  .withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF1976D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Tourist places count
          Positioned(
            top: 14,
            left: 14,
            child: _MapOverlayCard(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${touristPlaces.length} tourist places',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Current location information
          if (_location != null)
            Positioned(
              top: 68,
              left: 14,
              right: 14,
              child: _MapOverlayCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF1976D2),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your current location',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _location!.placeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.gps_fixed_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_off_rounded,
                        color: Colors.red,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Unable to get location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _loadLocation,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Current location button
          Positioned(
            right: 16,
            bottom: 22,
            child: Material(
              color: Colors.white,
              elevation: 6,
              shadowColor:
                  Colors.black.withValues(alpha: 0.20),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _goToCurrentLocation,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFF1976D2),
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapOverlayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _MapOverlayCard({
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}