import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/food_service.dart';
import '../../services/location_service.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final FoodService _foodService = FoodService();
  final LocationService _locationService = LocationService();

  List<FoodPlace> _allPlaces = <FoodPlace>[];
  List<FoodPlace> _filteredPlaces = <FoodPlace>[];

  bool _loading = true;
  String? _errorMessage;

  String _selectedFilter = 'All';

  double? _currentLatitude;
  double? _currentLongitude;

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_applyFilters);
    _loadFoodPlaces();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodPlaces() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final location =
          await _locationService.getCurrentLocation();

      _currentLatitude = location.latitude;
      _currentLongitude = location.longitude;

      final List<FoodPlace> places =
          await _foodService.getNearbyFood(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusMeters: 2000,
      );

      places.sort((a, b) {
        final double distanceA = _calculateDistance(
          a.latitude,
          a.longitude,
        );

        final double distanceB = _calculateDistance(
          b.latitude,
          b.longitude,
        );

        return distanceA.compareTo(distanceB);
      });

      if (!mounted) return;

      setState(() {
        _allPlaces = places;
        _loading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double _calculateDistance(
    double latitude,
    double longitude,
  ) {
    if (_currentLatitude == null ||
        _currentLongitude == null) {
      return 0;
    }

    const double earthRadius = 6371;

    final double dLat =
        (latitude - _currentLatitude!) * pi / 180;

    final double dLon =
        (longitude - _currentLongitude!) * pi / 180;

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_currentLatitude! * pi / 180) *
            cos(latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c =
        2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  void _applyFilters() {
    final String search =
        _searchController.text.trim().toLowerCase();

    List<FoodPlace> filtered =
        List<FoodPlace>.from(_allPlaces);

    if (_selectedFilter != 'All') {
      filtered = filtered.where(
        (FoodPlace place) {
          return place.displayType == _selectedFilter;
        },
      ).toList();
    }

    if (search.isNotEmpty) {
      filtered = filtered.where(
        (FoodPlace place) {
          return place.name.toLowerCase().contains(search) ||
              place.address.toLowerCase().contains(search) ||
              place.cuisine.toLowerCase().contains(search);
        },
      ).toList();
    }

    if (!mounted) return;

    setState(() {
      _filteredPlaces = filtered;
    });
  }

  Future<void> _openMap(FoodPlace place) async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${place.latitude},${place.longitude}'
      '&travelmode=driving',
    );

    try {
      final bool opened = await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open Google Maps.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open Google Maps.',
          ),
        ),
      );
    }
  }

  Future<void> _callPhone(
    FoodPlace place,
  ) async {
    if (place.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phone number is not available.',
          ),
        ),
      );

      return;
    }

    final Uri uri = Uri.parse(
      'tel:${place.phone}',
    );

    try {
      await launchUrl(uri);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Calling is not available on this device/browser.',
          ),
        ),
      );
    }
  }

  Future<void> _openWebsite(
    FoodPlace place,
  ) async {
    if (place.website.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Website is not available.',
          ),
        ),
      );

      return;
    }

    String url = place.website.trim();

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open website.',
          ),
        ),
      );
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Cafe':
        return Icons.coffee_rounded;
      case 'Fast Food':
        return Icons.fastfood_rounded;
      case 'Food Court':
        return Icons.restaurant_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Cafe':
        return Colors.brown;
      case 'Fast Food':
        return Colors.orange;
      case 'Food Court':
        return Colors.purple;
      default:
        return Colors.blue;
    }
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
          'Nearby Food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadFoodPlaces,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFoodPlaces,
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

            _buildSearchField(),

            const SizedBox(height: 12),

            _buildFilterSection(),

            const SizedBox(height: 18),

            if (_loading)
              _buildLoadingState(),

            if (!_loading &&
                _errorMessage != null)
              _buildErrorState(),

            if (!_loading &&
                _errorMessage == null &&
                _filteredPlaces.isEmpty)
              _buildEmptyState(),

            if (!_loading &&
                _errorMessage == null &&
                _filteredPlaces.isNotEmpty)
              _buildResultsHeader(),

            if (!_loading &&
                _errorMessage == null)
              ..._filteredPlaces.map(
                _buildFoodCard,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE65100),
            Color(0xFFFF8A50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(
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
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Near You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Discover restaurants, cafes and fast food within 2 km.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search food places...',
          hintStyle: const TextStyle(
            color: Colors.black45,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFE65100),
          ),
          suffixIcon:
              _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(
                        Icons.clear_rounded,
                      ),
                    ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('All'),
          _filterChip('Restaurant'),
          _filterChip('Cafe'),
          _filterChip('Fast Food'),
          _filterChip('Food Court'),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool selected =
        _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });

          _applyFilters();
        },
        selectedColor:
            const Color(0xFFFFE0D2),
        backgroundColor: Colors.white,
        checkmarkColor:
            const Color(0xFFE65100),
        side: BorderSide(
          color: selected
              ? const Color(0xFFFFB99A)
              : Colors.grey.shade200,
        ),
        labelStyle: TextStyle(
          color: selected
              ? const Color(0xFFE65100)
              : Colors.black87,
          fontWeight: selected
              ? FontWeight.w600
              : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
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
            'Finding nearby food places...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: Colors.red,
              size: 35,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Unable to load nearby food',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
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
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _loadFoodPlaces,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 36,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No food places found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Try another search or refresh your location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          const Text(
            'Nearby Food Places',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Text(
              '${_filteredPlaces.length} found',
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodPlace place) {
    final Color color =
        _typeColor(place.displayType);

    final double distance =
        _calculateDistance(
      place.latitude,
      place.longitude,
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _typeIcon(
                      place.displayType,
                    ),
                    color: color,
                    size: 29,
                  ),
                ),

                const SizedBox(width: 13),

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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          place.displayType,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(10),
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
                    distance < 1
                        ? '${(distance * 1000).round()} m away'
                        : '${distance.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (place.address.isNotEmpty)
              _InfoRow(
                icon:
                    Icons.location_on_outlined,
                text: place.address,
              ),

            if (place.cuisine.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon:
                    Icons.restaurant_menu_outlined,
                text: 'Cuisine: ${place.cuisine}',
              ),
            ],

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openMap(place),
                    icon: const Icon(
                      Icons.directions_rounded,
                      size: 19,
                    ),
                    label: const Text(
                      'Navigate',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),
                    ),
                  ),
                ),

                if (place.phone.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _ActionIconButton(
                    tooltip: 'Call',
                    icon: Icons.phone_rounded,
                    color: Colors.green,
                    onPressed: () =>
                        _callPhone(place),
                  ),
                ],

                if (place.website.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _ActionIconButton(
                    tooltip: 'Website',
                    icon: Icons.language_rounded,
                    color: Colors.blue,
                    onPressed: () =>
                        _openWebsite(place),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}