import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/tourist_place.dart';
import '../../services/geofence_service.dart';

class PlaceDetailsPage extends StatefulWidget {
  final TouristPlace place;

  const PlaceDetailsPage({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool _isVisited = false;
  bool _savingVisit = false;

  // Geo-fencing states
  bool _checkingGeofence = true;
  bool _isInsideGeofence = false;
  double? _distanceFromPlaceMeters;

  // Same radius used for this place's geofence.
  static const double _geofenceRadiusMeters = 500;

  // Actual Firestore document ID inside tourists collection.
  String? _touristDocumentId;

  String _touristId = '';

  // ------------------------------------------------------------
  // FIREBASE USER UID
  // ------------------------------------------------------------

  Future<void> _loadTouristId() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('tourists')
              .where(
                'uid',
                isEqualTo: user.uid,
              )
              .limit(1)
              .get();

      if (!mounted) {
        return;
      }

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _touristId = snapshot.docs.first.id;
        });

        await _checkVisitedStatus();
      }
    } catch (e) {
      debugPrint(
        'Error finding tourist profile: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // PLACE ID
  // ------------------------------------------------------------

  String get _placeId {
    return widget.place.name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  @override
  void initState() {
    super.initState();

    _loadTouristId();
    _checkGeofence();
  }

  // ------------------------------------------------------------
  // GET ACTUAL TOURIST DOCUMENT ID
  // ------------------------------------------------------------

  Future<String?> _getTouristDocumentId() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint(
        'No authenticated Firebase user found.',
      );

      return null;
    }

    if (_touristDocumentId != null) {
      return _touristDocumentId;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('tourists')
              .where(
                'uid',
                isEqualTo: user.uid,
              )
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        debugPrint(
          'No tourist document found for UID: ${user.uid}',
        );

        return null;
      }

      _touristDocumentId = snapshot.docs.first.id;

      debugPrint(
        'Tourist document ID found: $_touristDocumentId',
      );

      return _touristDocumentId;
    } catch (e) {
      debugPrint(
        'Error finding tourist document ID: $e',
      );

      return null;
    }
  }

  // ------------------------------------------------------------
  // CHECK VISITED STATUS
  // ------------------------------------------------------------

  Future<void> _checkVisitedStatus() async {
    final String? touristDocumentId =
        await _getTouristDocumentId();

    if (touristDocumentId == null ||
        _placeId.isEmpty) {
      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('tourists')
              .doc(touristDocumentId)
              .collection('visitedPlaces')
              .doc(_placeId)
              .get();

      if (!mounted) {
        return;
      }

      setState(() {
        _isVisited = snapshot.exists;
      });
    } catch (e) {
      debugPrint(
        'Error checking visited status: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // CHECK GEO-FENCE
  // ------------------------------------------------------------

  Future<void> _checkGeofence() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _checkingGeofence = true;
    });

    try {
      final GeofenceService geofenceService =
          GeofenceService();

      final List<GeofenceResult> results =
          await geofenceService.checkZones(
        <GeofenceZone>[
          GeofenceZone(
            id: _placeId,
            name: widget.place.name,
            latitude: widget.place.latitude,
            longitude: widget.place.longitude,
            radiusMeters: _geofenceRadiusMeters,
          ),
        ],
      );

      if (!mounted) {
        return;
      }

      if (results.isEmpty) {
        setState(() {
          _checkingGeofence = false;
          _isInsideGeofence = false;
          _distanceFromPlaceMeters = null;
        });

        return;
      }

      final GeofenceResult result = results.first;

      setState(() {
        _distanceFromPlaceMeters = result.distanceMeters;
        _isInsideGeofence = result.isInside;
        _checkingGeofence = false;
      });
    } catch (e) {
      debugPrint(
        'Error checking geofence: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _checkingGeofence = false;
        _isInsideGeofence = false;
        _distanceFromPlaceMeters = null;
      });
    }
  }

  // ------------------------------------------------------------
  // FORMAT DISTANCE
  // ------------------------------------------------------------

  String _formatDistance(double? meters) {
    if (meters == null) {
      return 'Distance unavailable';
    }

    if (meters < 1000) {
      return '${meters.round()} meters';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  // ------------------------------------------------------------
  // MARK AS VISITED
  // ------------------------------------------------------------

  Future<void> _markAsVisited() async {
    if (_savingVisit) {
      return;
    }

    if (_touristId.isEmpty) {
      await _loadTouristId();
    }

    if (_touristId.isEmpty) {
      _showMessage(
        'Unable to find your tourist profile. Please try again.',
      );
      return;
    }

    if (_placeId.isEmpty) {
      _showMessage(
        'Unable to identify this place.',
      );

      return;
    }

    // ----------------------------------------------------------
    // FRESH GEO-FENCE CHECK
    // ----------------------------------------------------------

    try {
      final GeofenceService geofenceService =
          GeofenceService();

      final List<GeofenceResult> results =
          await geofenceService.checkZones(
        <GeofenceZone>[
          GeofenceZone(
            id: _placeId,
            name: widget.place.name,
            latitude: widget.place.latitude,
            longitude: widget.place.longitude,
            radiusMeters: _geofenceRadiusMeters,
          ),
        ],
      );

      if (!mounted) {
        return;
      }

      if (results.isEmpty) {
        _showMessage(
          'Could not verify your current location.',
        );

        return;
      }

      final GeofenceResult result = results.first;

      setState(() {
        _isInsideGeofence = result.isInside;
        _distanceFromPlaceMeters = result.distanceMeters;
      });

      if (!result.isInside) {
        _showMessage(
          'You can mark this place as visited only when you are within 500 meters of it.',
        );

        return;
      }
    } catch (e) {
      debugPrint(
        'Error during fresh geofence check: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not verify your current location. Please try again.',
      );

      return;
    }

    // ----------------------------------------------------------
    // CONFIRM VISIT
    // ----------------------------------------------------------

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirm Visit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Did you actually visit ${widget.place.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Yes, I Visited',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // GET ACTUAL TOURIST DOCUMENT ID
    // ----------------------------------------------------------

    final String? touristDocumentId =
        await _getTouristDocumentId();

    if (touristDocumentId == null) {
      if (mounted) {
        _showMessage(
          'Unable to find your tourist account.',
        );
      }

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _savingVisit = true;
    });

    // ----------------------------------------------------------
    // SAVE VISIT TO FIRESTORE
    // ----------------------------------------------------------

    try {
      await FirebaseFirestore.instance
          .collection('tourists')
          .doc(touristDocumentId)
          .collection('visitedPlaces')
          .doc(_placeId)
          .set({
        'placeId': _placeId,
        'placeName': widget.place.name,
        'category': widget.place.category,
        'latitude': widget.place.latitude,
        'longitude': widget.place.longitude,
        'visitedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isVisited = true;
        _savingVisit = false;
      });

      _showMessage(
        '${widget.place.name} added to your travel history.',
      );
    } catch (e) {
      debugPrint(
        'Unable to save visit: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _savingVisit = false;
      });

      _showMessage(
        'Unable to save your visit. Error: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // NAVIGATE TO PLACE
  // ------------------------------------------------------------

  Future<void> _navigateToPlace() async {
    final String destination =
        '${widget.place.name}, Mumbai, Maharashtra';

    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${Uri.encodeComponent(destination)}'
      '&travelmode=driving'
      '&dir_action=navigate',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) {
          return;
        }

        _showMessage(
          'Could not open Google Maps.',
        );
      }
    } catch (e) {
      debugPrint(
        'Error opening Google Maps: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not open Google Maps.',
      );
    }
  }

  // ------------------------------------------------------------
  // OPEN GOOGLE MAPS
  // ------------------------------------------------------------

  Future<void> _openGoogleMaps() async {
    final double latitude = widget.place.latitude;
    final double longitude = widget.place.longitude;

    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) {
          return;
        }

        _showMessage(
          'Could not open Google Maps.',
        );
      }
    } catch (e) {
      debugPrint(
        'Error opening Google Maps: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not open Google Maps.',
      );
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
  }

  // ------------------------------------------------------------
  // SECTION WIDGET
  // ------------------------------------------------------------

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BULLET LIST
  // ------------------------------------------------------------

  Widget _bulletList(
    List<String> items,
    Color iconColor,
  ) {
    if (items.isEmpty) {
      return Text(
        'No information available.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      );
    }

    return Column(
      children: items.map(
        (item) {
          return Container(
            margin: const EdgeInsets.only(
              bottom: 8,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: iconColor,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final TouristPlace place = widget.place;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Place Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _checkingGeofence
                ? null
                : _checkGeofence,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkVisitedStatus();
          await _checkGeofence();
        },
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // HERO HEADER
              // --------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  26,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEAF4FF),
                      Color(0xFFF6FAFF),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue
                                .withValues(
                              alpha: 0.10,
                            ),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight:
                                  FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              place.category,
                              style: const TextStyle(
                                color: Colors.white,
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
              ),

              // --------------------------------------------------
              // MAIN CONTENT
              // --------------------------------------------------

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // NAVIGATE BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToPlace,
                        icon: const Icon(
                          Icons.navigation_rounded,
                        ),
                        label: const Text(
                          'Navigate to this place',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Colors.blue,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // DISTANCE CARD
                    // ------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.035,
                            ),
                            blurRadius: 10,
                            offset:
                                const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  Colors.blue.withValues(
                                alpha: 0.09,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Distance from place',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _checkingGeofence
                                      ? 'Checking...'
                                      : _formatDistance(
                                          _distanceFromPlaceMeters,
                                        ),
                                  style: TextStyle(
                                    color: Colors
                                        .grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_checkingGeofence &&
                              _distanceFromPlaceMeters !=
                                  null)
                            Text(
                              _isInsideGeofence
                                  ? 'Nearby'
                                  : 'Away',
                              style: TextStyle(
                                color:
                                    _isInsideGeofence
                                        ? Colors.green
                                        : Colors.orange,
                                fontWeight:
                                    FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // GEO-FENCE STATUS
                    // ------------------------------------------------

                    if (_checkingGeofence)
                      _StatusCard(
                        icon: Icons.my_location,
                        title:
                            'Checking your location...',
                        message:
                            'Please wait while we verify your current location.',
                        color: Colors.blue,
                        backgroundColor:
                            Colors.blue.shade50,
                      )
                    else if (_isInsideGeofence &&
                        !_isVisited)
                      _StatusCard(
                        icon: Icons.location_on,
                        title:
                            'You are inside the tourist zone',
                        message:
                            _distanceFromPlaceMeters !=
                                    null
                                ? 'Distance: ${_distanceFromPlaceMeters!.round()} meters'
                                : 'You are within 500 meters of this place.',
                        color: Colors.green,
                        backgroundColor:
                            Colors.green.shade50,
                      )
                    else if (!_isVisited)
                      _StatusCard(
                        icon: Icons.location_off,
                        title:
                            'You are outside the tourist zone',
                        message:
                            _distanceFromPlaceMeters !=
                                    null
                                ? 'You are ${_distanceFromPlaceMeters!.round()} meters away. Come within 500 meters to mark this place as visited.'
                                : 'Come within 500 meters of this place to mark it as visited.',
                        color: Colors.orange,
                        backgroundColor:
                            Colors.orange.shade50,
                      ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // VISITED BUTTON
                    // ------------------------------------------------

                    if (_isVisited)
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                Colors.green.shade200,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You have visited this place',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_isInsideGeofence)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _savingVisit
                              ? null
                              : _markAsVisited,
                          icon: _savingVisit
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .location_on_rounded,
                                ),
                          label: Text(
                            _savingVisit
                                ? 'Saving Visit...'
                                : 'I Visited This Place',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                Colors.teal,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 15,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // ABOUT
                    // ------------------------------------------------

                    _section(
                      title: 'About',
                      icon: Icons.info_outline_rounded,
                      child: Text(
                        place.about,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // HISTORY
                    // ------------------------------------------------

                    _section(
                      title: 'History',
                      icon: Icons.history_rounded,
                      child: Text(
                        place.history,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // THINGS TO DO
                    // ------------------------------------------------

                    _section(
                      title: 'Things To Do',
                      icon: Icons.explore_rounded,
                      child: _bulletList(
                        place.thingsToDo,
                        Colors.green,
                      ),
                    ),

                    // ------------------------------------------------
                    // SAFETY TIPS
                    // ------------------------------------------------

                    _section(
                      title: 'Safety Tips',
                      icon: Icons.shield_outlined,
                      child: _bulletList(
                        place.safetyTips,
                        Colors.orange,
                      ),
                    ),

                    // ------------------------------------------------
                    // NEARBY FOOD
                    // ------------------------------------------------

                    _section(
                      title: 'Nearby Food',
                      icon: Icons.restaurant_outlined,
                      child: _bulletList(
                        place.nearbyFood,
                        Colors.red,
                      ),
                    ),

                    // ------------------------------------------------
                    // VISITING INFORMATION
                    // ------------------------------------------------

                    _section(
                      title: 'Visiting Information',
                      icon: Icons.access_time_rounded,
                      child: Text(
                        place.visitingInfo,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // PLAN TIPS
                    // ------------------------------------------------

                    _section(
                      title: 'Plan Tips',
                      icon: Icons.lightbulb_outline_rounded,
                      child: Text(
                        place.planTips,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // COORDINATES
                    // ------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.035,
                            ),
                            blurRadius: 10,
                            offset:
                                const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  Colors.blue.withValues(
                                alpha: 0.09,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Location Coordinates',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${place.latitude}, ${place.longitude}',
                                  style: TextStyle(
                                    color: Colors
                                        .grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------------
                    // OPEN GOOGLE MAPS
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openGoogleMaps,
                        icon: const Icon(
                          Icons.map_outlined,
                        ),
                        label: const Text(
                          'Open in Google Maps',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.blue,
                          side: BorderSide(
                            color: Colors.blue.shade200,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// STATUS CARD
// ======================================================

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color backgroundColor;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12.5,
                    height: 1.4,
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