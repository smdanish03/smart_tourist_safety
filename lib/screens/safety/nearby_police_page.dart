import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/police_station_service.dart';

class NearbyPolicePage extends StatefulWidget {
  const NearbyPolicePage({super.key});

  @override
  State<NearbyPolicePage> createState() => _NearbyPolicePageState();
}

class _NearbyPolicePageState extends State<NearbyPolicePage> {
  final PoliceStationService _policeStationService =
      PoliceStationService();

  List<NearbyPoliceStation> _stations = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPoliceStations();
  }

  Future<void> _loadPoliceStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<NearbyPoliceStation> stations =
          await _policeStationService.getNearbyPoliceStations(
        radiusKm: 10,
      );

      if (!mounted) return;

      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      final int meters = (distanceKm * 1000).round();
      return '$meters m away';
    }

    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  Future<void> _callPoliceStation(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _navigateToPoliceStation(
    NearbyPoliceStation nearby,
  ) async {
    final String destination =
        '${nearby.station.name}, '
        '${nearby.station.latitude},'
        '${nearby.station.longitude}';

    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${Uri.encodeComponent(destination)}'
      '&travelmode=driving'
      '&dir_action=navigate',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Nearby Police',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadPoliceStations,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF172033),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              'Finding nearby police stations...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_police_outlined,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to find police stations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _loadPoliceStations,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_stations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPoliceStations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 150),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_police_outlined,
                  size: 38,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'No police stations found nearby',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Center(
              child: Text(
                'Pull down to refresh your location.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPoliceStations,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        children: [
          // --------------------------------------------------
          // Nearby Police Header
          // --------------------------------------------------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_police_rounded,
                    color: Colors.blue,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Police stations near you',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_stations.length} police stations found within 10 km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Nearby Stations',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 10),

          ..._stations.asMap().entries.map(
            (entry) {
              final int index = entry.key;
              final NearbyPoliceStation nearby = entry.value;

              return _PoliceStationCard(
                rank: index + 1,
                nearby: nearby,
                distanceText: _formatDistance(
                  nearby.distanceKm,
                ),
                onCall: nearby.station.phone == null
                    ? null
                    : () {
                        _callPoliceStation(
                          nearby.station.phone!,
                        );
                      },
                onNavigate: () {
                  _navigateToPoliceStation(nearby);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Police Station Card
// --------------------------------------------------

class _PoliceStationCard extends StatelessWidget {
  final int rank;
  final NearbyPoliceStation nearby;
  final String distanceText;
  final VoidCallback? onCall;
  final VoidCallback onNavigate;

  const _PoliceStationCard({
    required this.rank,
    required this.nearby,
    required this.distanceText,
    required this.onCall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final station = nearby.station;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // Station Name
          // --------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_police_rounded,
                  color: Colors.blue,
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------
          // Distance
          // --------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.near_me_rounded,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  distanceText,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 11),

          // --------------------------------------------------
          // Address
          // --------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  station.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // --------------------------------------------------
          // Actions
          // --------------------------------------------------
          Row(
            children: [
              if (onCall != null)
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(
                        Icons.phone_rounded,
                        size: 17,
                      ),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(
                          color: Colors.green.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(11),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              if (onCall != null)
                const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(
                      Icons.navigation_rounded,
                      size: 17,
                    ),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}