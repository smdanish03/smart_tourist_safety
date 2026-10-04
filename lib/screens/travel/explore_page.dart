import 'package:flutter/material.dart';

import '../../data/tourist_places.dart';
import '../../models/tourist_place.dart';
import 'my_trips_page.dart';
import 'place_details_page.dart';
import 'trip_planner_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ======================================================
  // CATEGORY LIST
  // ======================================================

  List<String> get _categories {
    final List<String> categories = [
      'All',
      'Historical',
      'Beach',
      'Heritage',
      'Nature',
      'Religious',
      'Garden',
      'Market',
      'Scenic',
      'Spiritual',
      'Other',
    ];

    return categories.where((category) {
      if (category == 'All') {
        return true;
      }

      return touristPlaces.any(
        (place) =>
            _getCategoryGroup(place.category) == category,
      );
    }).toList();
  }

  // ======================================================
  // CATEGORY GROUPING
  // ======================================================

  String _getCategoryGroup(String actualCategory) {
    final String category = actualCategory.toLowerCase();

    if (category.contains('historical') ||
        category.contains('history')) {
      return 'Historical';
    }

    if (category.contains('beach') ||
        category.contains('waterfront') ||
        category.contains('coastal')) {
      return 'Beach';
    }

    if (category.contains('heritage') ||
        category.contains('unesco')) {
      return 'Heritage';
    }

    if (category.contains('nature') ||
        category.contains('forest') ||
        category.contains('wildlife')) {
      return 'Nature';
    }

    if (category.contains('religious') ||
        category.contains('temple') ||
        category.contains('church') ||
        category.contains('mosque') ||
        category.contains('dargah') ||
        category.contains('basilica')) {
      return 'Religious';
    }

    if (category.contains('garden') ||
        category.contains('park')) {
      return 'Garden';
    }

    if (category.contains('market') ||
        category.contains('shopping')) {
      return 'Market';
    }

    if (category.contains('scenic') ||
        category.contains('viewpoint')) {
      return 'Scenic';
    }

    if (category.contains('spiritual') ||
        category.contains('meditation')) {
      return 'Spiritual';
    }

    return 'Other';
  }

  // ======================================================
  // FILTERED PLACES
  // ======================================================

  List<TouristPlace> get _filteredPlaces {
    final String search =
        _searchText.trim().toLowerCase();

    return touristPlaces.where((place) {
      final bool matchesCategory =
          _selectedCategory == 'All' ||
          _getCategoryGroup(place.category) ==
              _selectedCategory;

      final bool matchesSearch =
          search.isEmpty ||
          place.name.toLowerCase().contains(search) ||
          place.category.toLowerCase().contains(search) ||
          place.about.toLowerCase().contains(search);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ======================================================
  // OPEN PLACE DETAILS
  // ======================================================

  void _openPlace(TouristPlace place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailsPage(
          place: place,
        ),
      ),
    );
  }

  // ======================================================
  // CATEGORY ICON
  // ======================================================

  IconData _getCategoryIcon(String category) {
    switch (_getCategoryGroup(category)) {
      case 'Historical':
        return Icons.account_balance;

      case 'Beach':
        return Icons.beach_access;

      case 'Heritage':
        return Icons.museum;

      case 'Nature':
        return Icons.forest;

      case 'Religious':
        return Icons.temple_hindu;

      case 'Garden':
        return Icons.local_florist;

      case 'Market':
        return Icons.storefront;

      case 'Scenic':
        return Icons.landscape;

      case 'Spiritual':
        return Icons.self_improvement;

      default:
        return Icons.location_city;
    }
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final List<TouristPlace> places = _filteredPlaces;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Explore Mumbai',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Trip Planner',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withValues(
                alpha: 0.08,
              ),
            ),
            icon: const Icon(
              Icons.event_note_outlined,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TripPlannerPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'My Trips',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withValues(
                alpha: 0.08,
              ),
            ),
            icon: const Icon(
              Icons.luggage_outlined,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyTripsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ==================================================
          // SEARCH SECTION
          // ==================================================

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search tourist places...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.blue,
                    ),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();

                              setState(() {
                                _searchText = '';
                              });
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF6F8FC),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Explore by category',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // CATEGORY CHIPS
                // ==================================================

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map(
                      (category) {
                        final bool selected =
                            category ==
                                _selectedCategory;

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            right: 8,
                          ),
                          child: ChoiceChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            selected: selected,
                            showCheckmark: false,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                            backgroundColor:
                                Colors.white,
                            selectedColor:
                                Colors.blue,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory =
                                    category;
                              });
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // RESULT HEADER
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 19,
                  color: Colors.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  '${places.length} places found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (_selectedCategory != 'All')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ==================================================
          // PLACES LIST
          // ==================================================

          Expanded(
            child: places.isEmpty
                ? const _EmptySearchResult()
                : ListView.builder(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      6,
                      16,
                      24,
                    ),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final TouristPlace place =
                          places[index];

                      return _TouristPlaceCard(
                        place: place,
                        icon: _getCategoryIcon(
                          place.category,
                        ),
                        onTap: () =>
                            _openPlace(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// EMPTY SEARCH RESULT
// ======================================================

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No tourist places found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Try another search or category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// TOURIST PLACE CARD
// ======================================================

class _TouristPlaceCard extends StatelessWidget {
  final TouristPlace place;
  final IconData icon;
  final VoidCallback onTap;

  const _TouristPlaceCard({
    required this.place,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // PLACE ICON
                // ==================================================

                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade100,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade700,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 13),

                // ==================================================
                // PLACE INFORMATION
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 21,
                            color:
                                Colors.grey.shade400,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // CATEGORY
                      // ==================================================

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.blue.withValues(
                            alpha: 0.09,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          place.category,
                          style: TextStyle(
                            fontSize: 10.5,
                            color:
                                Colors.blue.shade700,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // ABOUT
                      // ==================================================

                      Text(
                        place.about,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color:
                              Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // LOCATION
                      // ==================================================

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color:
                                Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${place.latitude.toStringAsFixed(4)}, '
                              '${place.longitude.toStringAsFixed(4)}',
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                color:
                                    Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // VIEW DETAILS
                      // ==================================================

                      Row(
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color:
                                  Colors.blue.shade700,
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color:
                                Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ],
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