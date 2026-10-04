import 'package:flutter/material.dart';

import '../../services/nearby_places_service.dart';
import 'place_details_page.dart';

class NearbyPlacesPage extends StatefulWidget {
  const NearbyPlacesPage({super.key});

  @override
  State<NearbyPlacesPage> createState() =>
      _NearbyPlacesPageState();
}

class _NearbyPlacesPageState
    extends State<NearbyPlacesPage> {
  final NearbyPlacesService _nearbyPlacesService =
      NearbyPlacesService();

  List<NearbyTouristPlace> _places = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<NearbyTouristPlace> places =
          await _nearbyPlacesService.getNearbyPlaces();

      if (!mounted) return;

      setState(() {
        _places = places;
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
      final int meters =
          (distanceKm * 1000).round();

      return '$meters m away';
    }

    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  IconData _getCategoryIcon(String category) {
    final String value = category.toLowerCase();

    if (value.contains('beach')) {
      return Icons.beach_access_rounded;
    }

    if (value.contains('nature') ||
        value.contains('forest') ||
        value.contains('wildlife')) {
      return Icons.forest_rounded;
    }

    if (value.contains('temple') ||
        value.contains('religious') ||
        value.contains('church') ||
        value.contains('mosque') ||
        value.contains('dargah')) {
      return Icons.temple_hindu_rounded;
    }

    if (value.contains('garden') ||
        value.contains('park')) {
      return Icons.local_florist_rounded;
    }

    if (value.contains('museum') ||
        value.contains('heritage') ||
        value.contains('historical')) {
      return Icons.account_balance_rounded;
    }

    if (value.contains('market')) {
      return Icons.storefront_rounded;
    }

    return Icons.location_city_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Nearby Places',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadNearbyPlaces,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
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
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 14),
            Text(
              'Finding nearby tourist places...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.06,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to find nearby places',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadNearbyPlaces,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_places.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNearbyPlaces,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 150),
            Container(
              width: 82,
              height: 82,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_searching_rounded,
                size: 42,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'No tourist places found nearby',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 7),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  'Try again after moving to another area.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyPlaces,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        children: [
          _buildHeaderCard(),

          const SizedBox(height: 18),

          ..._places.asMap().entries.map(
            (entry) {
              final int index = entry.key;
              final NearbyTouristPlace nearby =
                  entry.value;

              return _NearbyPlaceCard(
                rank: index + 1,
                nearbyPlace: nearby,
                distanceText:
                    _formatDistance(
                  nearby.distanceKm,
                ),
                icon: _getCategoryIcon(
                  nearby.place.category,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PlaceDetailsPage(
                        place: nearby.place,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(
              alpha: 0.18,
            ),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.near_me_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Places near you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_places.length} tourist places found within 20 km',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyPlaceCard extends StatelessWidget {
  final int rank;
  final NearbyTouristPlace nearbyPlace;
  final String distanceText;
  final IconData icon;
  final VoidCallback onTap;

  const _NearbyPlaceCard({
    required this.rank,
    required this.nearbyPlace,
    required this.distanceText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final place = nearbyPlace.place;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.045,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 31,
                  height: 31,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Category icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1976D2),
                    size: 29,
                  ),
                ),

                const SizedBox(width: 12),

                // Information
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                        child: Text(
                          place.category,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1976D2),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.near_me_rounded,
                            size: 15,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black54,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}