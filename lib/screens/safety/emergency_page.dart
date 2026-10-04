import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/incident.dart';
import '../../services/incident_service.dart';
import '../../services/location_service.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final LocationService _locationService = LocationService();
  final IncidentService _incidentService = IncidentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loadingLocation = false;
  bool _sendingSOS = false;
  bool _sosActivated = false;

  double? _latitude;
  double? _longitude;

  String? _locationName;
  DateTime? _sosTime;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    if (_loadingLocation || !mounted) {
      return;
    }

    setState(() {
      _loadingLocation = true;
    });

    try {
      final location =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _locationName = location.placeName;
        _loadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get current location. Please check location permission.',
          ),
        ),
      );
    }
  }

  Future<void> _activateSOS() async {
    if (_sendingSOS || _sosActivated) {
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Activate SOS?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'SOS will send an emergency report to the admin with your tourist details and current location.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Activate SOS'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before using SOS.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _sendingSOS = true;
      _loadingLocation = true;
    });

    try {
      // 1. Get fresh location.
      final location =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _locationName = location.placeName;
        _loadingLocation = false;
      });

      // 2. Get tourist ID.
      String touristId = 'UNKNOWN';

      final String? authEmail = user.email;

      if (authEmail != null && authEmail.contains('@')) {
        touristId =
            authEmail.split('@').first.toUpperCase();
      }

      // 3. Get tourist profile.
      String touristName =
          user.displayName ?? 'Unknown Tourist';

      String email = user.email ?? '';
      String phone = 'Not provided';
      String city = 'Not provided';

      try {
        final touristDocument = await _firestore
            .collection('tourists')
            .doc(touristId)
            .get();

        final data = touristDocument.data();

        if (data != null) {
          touristName =
              data['fullName']?.toString() ??
                  data['name']?.toString() ??
                  touristName;

          email = data['email']?.toString() ?? email;

          phone =
              data['phone']?.toString() ?? phone;

          city =
              data['city']?.toString() ?? city;
        }
      } catch (_) {
        // Profile failure should not stop SOS.
      }

      // 4. Create report ID.
      final DateTime now = DateTime.now();

      final String reportId =
          'SOS-${now.millisecondsSinceEpoch}';

      // 5. Create SOS incident.
      final Incident sosIncident = Incident(
        reportId: reportId,
        touristId: touristId,
        uid: user.uid,
        touristName: touristName,
        email: email,
        phone: phone,
        city: city,
        incidentType: 'SOS Emergency',
        description:
            'Emergency SOS activated by the tourist. Immediate assistance may be required.',
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.placeName,
        createdAt: now,
        status: 'Submitted',
      );

      // 6. Submit to Firestore.
      await _incidentService.submitIncident(
        sosIncident,
      );

      if (!mounted) return;

      // 7. Update UI.
      setState(() {
        _sosActivated = true;
        _sosTime = now;
        _sendingSOS = false;
        _loadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🚨 SOS activated. Admin has received your emergency report.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _sendingSOS = false;
        _loadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SOS could not be sent to admin.\n$error',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _makeEmergencyCall(
    BuildContext context,
    String number,
    String service,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Emergency Call',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to call $service ($number)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Call'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    if (kIsWeb) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Phone calls are available in the Android app. Call $number manually on your phone.',
          ),
        ),
      );

      return;
    }

    final Uri uri = Uri.parse('tel:$number');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to open phone dialer for $number.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the phone dialer.',
          ),
        ),
      );
    }
  }

  Future<void> _openCurrentLocation() async {
    if (_latitude == null || _longitude == null) {
      await _loadCurrentLocation();
    }

    if (!mounted) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Current location is not available. Please enable location permission.',
          ),
        ),
      );

      return;
    }

    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude',
    );

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(
          mapsUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Google Maps.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Google Maps.'),
        ),
      );
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '';
    }

    final String hour =
        time.hour.toString().padLeft(2, '0');

    final String minute =
        time.minute.toString().padLeft(2, '0');

    final String second =
        time.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
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
          'Emergency SOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrentLocation,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            _buildSOSCard(),

            const SizedBox(height: 18),

            _buildLocationCard(),

            const SizedBox(height: 22),

            _buildSectionHeader(),

            const SizedBox(height: 12),

            _EmergencyButton(
              icon: Icons.emergency_rounded,
              title: 'Emergency',
              subtitle: 'National Emergency Number',
              number: '112',
              color: Colors.red,
              onPressed: () {
                _makeEmergencyCall(
                  context,
                  '112',
                  'Emergency Services',
                );
              },
            ),

            const SizedBox(height: 11),

            _EmergencyButton(
              icon: Icons.local_police_rounded,
              title: 'Police',
              subtitle: 'Police Control Room',
              number: '100',
              color: Colors.blue,
              onPressed: () {
                _makeEmergencyCall(
                  context,
                  '100',
                  'Police',
                );
              },
            ),

            const SizedBox(height: 11),

            _EmergencyButton(
              icon: Icons.support_agent_rounded,
              title: 'Women Helpline',
              subtitle: 'Women Helpline',
              number: '103',
              color: Colors.purple,
              onPressed: () {
                _makeEmergencyCall(
                  context,
                  '103',
                  'Women Helpline',
                );
              },
            ),

            const SizedBox(height: 18),

            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Row(
      children: [
        Icon(
          Icons.phone_in_talk_outlined,
          color: Colors.red,
          size: 22,
        ),
        SizedBox(width: 8),
        Text(
          'Emergency Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSOSCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _sosActivated
              ? [
                  Colors.red.shade800,
                  Colors.red.shade600,
                ]
              : [
                  Colors.red.shade700,
                  Colors.red.shade500,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _sosActivated
                  ? Icons.warning_rounded
                  : Icons.sos_rounded,
              color: Colors.white,
              size: 54,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _sosActivated ? 'SOS ACTIVE' : 'Emergency SOS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            _sosActivated
                ? 'Emergency assistance mode is currently active.'
                : 'Activate SOS when you need immediate emergency assistance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          if (!_sosActivated)
            SizedBox(
              width: double.infinity,
              height: 96,
              child: ElevatedButton(
                onPressed:
                    _sendingSOS ? null : _activateSOS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  disabledBackgroundColor:
                      Colors.white.withValues(alpha: 0.70),
                  disabledForegroundColor: Colors.red.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: _sendingSOS
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'SENDING...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'SOS',
                            style: TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'ACTIVATE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          if (_sosActivated) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 21,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'SOS is currently active',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Admin has received your emergency report.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 12,
                    ),
                  ),
                  if (_sosTime != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Activated at ${_formatTime(_sosTime)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _openCurrentLocation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.location_on_outlined),
                label: const Text(
                  'VIEW MY LOCATION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'The SOS remains active until an administrator reviews and resolves the emergency report.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh location',
                onPressed: _loadingLocation
                    ? null
                    : _loadCurrentLocation,
                icon: _loadingLocation
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),

          const SizedBox(height: 13),

          if (_latitude != null && _longitude != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_locationName != null &&
                      _locationName!.trim().isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 18,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            _locationName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                  ],
                  Text(
                    'Latitude  ${_latitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Longitude  ${_longitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openCurrentLocation,
                icon: const Icon(Icons.map_outlined),
                label: const Text(
                  'Open Location in Google Maps',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (_loadingLocation) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Getting your current location...'),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Current location is not available.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadCurrentLocation,
                icon: const Icon(
                  Icons.location_searching,
                ),
                label: const Text(
                  'Get Current Location',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'Only use emergency services when you genuinely need assistance. For immediate danger, contact the appropriate emergency service.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String number;
  final Color color;
  final VoidCallback onPressed;

  const _EmergencyButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.number,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(
                Icons.phone,
                size: 17,
              ),
              label: Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}