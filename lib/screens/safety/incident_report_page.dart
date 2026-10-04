import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/incident.dart';
import '../../services/incident_service.dart';
import '../../services/location_service.dart';

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() =>
      _IncidentReportPageState();
}

class _IncidentReportPageState
    extends State<IncidentReportPage> {
  final IncidentService _incidentService =
      IncidentService();

  final LocationService _locationService =
      LocationService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final List<String> _incidentTypes = [
    'Theft',
    'Harassment',
    'Accident',
    'Lost Person',
    'Medical Emergency',
    'Unsafe Area',
    'Suspicious Activity',
    'Other',
  ];

  String? _selectedIncidentType;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isLoadingProfile = true;

  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();

    _loadTouristProfile();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD TOURIST PROFILE
  // ------------------------------------------------------------

  Future<void> _loadTouristProfile() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
      });

      _showMessage(
        'Please login before reporting an incident.',
      );

      return;
    }

    try {
      Map<String, dynamic>? data;

      final QuerySnapshot<Map<String, dynamic>>
          uidSnapshot = await _firestore
              .collection('tourists')
              .where(
                'uid',
                isEqualTo: user.uid,
              )
              .limit(1)
              .get();

      if (uidSnapshot.docs.isNotEmpty) {
        data = uidSnapshot.docs.first.data();
      }

      if (data == null) {
        final String touristId =
            user.email
                    ?.split('@')
                    .first
                    .toUpperCase() ??
                'UNKNOWN';

        final DocumentSnapshot<
            Map<String, dynamic>> document =
            await _firestore
                .collection('tourists')
                .doc(touristId)
                .get();

        if (document.exists) {
          data = document.data();
        }
      }

      if (!mounted) return;

      setState(() {
        _nameController.text =
            data?['fullName']?.toString() ??
                data?['name']?.toString() ??
                '';

        _emailController.text =
            data?['email']?.toString() ??
                user.email ??
                '';

        _phoneController.text =
            data?['phone']?.toString() ??
                '';

        _cityController.text =
            data?['city']?.toString() ??
                '';

        _isLoadingProfile = false;
      });

      if (data == null) {
        _showMessage(
          'Tourist profile was not found. Please check your profile details.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _emailController.text =
            user.email ?? '';

        _isLoadingProfile = false;
      });

      _showMessage(
        'Unable to load profile details: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // LOAD CURRENT LOCATION
  // ------------------------------------------------------------

  Future<void> _loadCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final LocationData location =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _isGettingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGettingLocation = false;
      });

      _showMessage(
        'Unable to get current location: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // CREATE REPORT ID
  // ------------------------------------------------------------

  String _createReportId() {
    final int timestamp =
        DateTime.now().millisecondsSinceEpoch;

    return 'INC-$timestamp';
  }

  // ------------------------------------------------------------
  // SUBMIT INCIDENT REPORT
  // ------------------------------------------------------------

  Future<void> _submitReport() async {
    if (_selectedIncidentType == null) {
      _showMessage(
        'Please select an incident type.',
      );

      return;
    }

    final String description =
        _descriptionController.text.trim();

    if (description.isEmpty) {
      _showMessage(
        'Please describe the incident.',
      );

      return;
    }

    final String phone =
        _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage(
        'Please enter your phone number.',
      );

      return;
    }

    final String city =
        _cityController.text.trim();

    if (city.isEmpty) {
      _showMessage(
        'Please enter your city.',
      );

      return;
    }

    if (_currentLocation == null) {
      _showMessage(
        'Current location is required. Please try again.',
      );

      await _loadCurrentLocation();

      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please login before submitting a report.',
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String touristId =
          user.email
                  ?.split('@')
                  .first
                  .toUpperCase() ??
              'UNKNOWN';

      final String reportId =
          _createReportId();

      final Incident incident = Incident(
        reportId: reportId,
        touristId: touristId,
        uid: user.uid,
        touristName:
            _nameController.text.trim(),
        email:
            _emailController.text.trim(),
        phone: phone,
        city: city,
        incidentType:
            _selectedIncidentType!,
        description: description,
        latitude:
            _currentLocation!.latitude,
        longitude:
            _currentLocation!.longitude,
        locationName:
            _currentLocation!.placeName,
        createdAt:
            DateTime.now(),
        status: 'Submitted',
      );

      await _incidentService.submitIncident(
        incident,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      await _showSuccessDialog(
        incident.reportId,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Submit failed: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // SUCCESS DIALOG
  // ------------------------------------------------------------

  Future<void> _showSuccessDialog(
    String reportId,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          icon: Container(
            padding:
                const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 52,
            ),
          ),
          title: const Text(
            'Report Submitted',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your incident has been submitted successfully.\n\n'
            'Report ID: $reportId',
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration _profileInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF1976D2),
          width: 1.5,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
        title: const Text(
          'Report Incident',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // ------------------------------------------------------------
  // BODY
  // ------------------------------------------------------------

  Widget _buildBody() {
    if (_isLoadingProfile) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        32,
      ),
      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        Container(
          padding:
              const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF3E0),
                Colors.white,
              ],
            ),
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange
                  .withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.orange
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report an Incident',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Provide accurate information so the incident can be reviewed and handled appropriately.',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ------------------------------------------------------
        // TOURIST INFORMATION
        // ------------------------------------------------------

        _sectionTitle(
          icon: Icons.person_outline,
          title: 'Tourist Information',
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _nameController,
          readOnly: true,
          decoration:
              _profileInputDecoration(
            label: 'Tourist Name',
            icon: Icons.person_outline,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _emailController,
          readOnly: true,
          decoration:
              _profileInputDecoration(
            label: 'Email',
            icon: Icons.email_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _phoneController,
          keyboardType:
              TextInputType.phone,
          decoration:
              _profileInputDecoration(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _cityController,
          textCapitalization:
              TextCapitalization.words,
          decoration:
              _profileInputDecoration(
            label: 'City',
            icon:
                Icons.location_city_outlined,
          ),
        ),

        const SizedBox(height: 26),

        // ------------------------------------------------------
        // INCIDENT TYPE
        // ------------------------------------------------------

        _sectionTitle(
          icon: Icons.category_outlined,
          title: 'Incident Type',
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue:
              _selectedIncidentType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.category_outlined,
            ),
            hintText:
                'Select incident type',
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide:
                  const BorderSide(
                color: Color(0xFF1976D2),
                width: 1.5,
              ),
            ),
          ),
          items:
              _incidentTypes.map(
            (String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            },
          ).toList(),
          onChanged:
              (String? value) {
            setState(() {
              _selectedIncidentType =
                  value;
            });
          },
        ),

        const SizedBox(height: 26),

        // ------------------------------------------------------
        // DESCRIPTION
        // ------------------------------------------------------

        _sectionTitle(
          icon: Icons.description_outlined,
          title: 'Incident Description',
        ),

        const SizedBox(height: 12),

        TextField(
          controller:
              _descriptionController,
          maxLines: 6,
          maxLength: 500,
          textCapitalization:
              TextCapitalization.sentences,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            alignLabelWithHint: true,
            hintText:
                'Describe what happened...',
            hintStyle: const TextStyle(
              color: Colors.black38,
            ),
            prefixIcon: const Padding(
              padding:
                  EdgeInsets.only(bottom: 90),
              child: Icon(
                Icons.description_outlined,
              ),
            ),
            contentPadding:
                const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              14,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide:
                  const BorderSide(
                color: Color(0xFF1976D2),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // LOCATION CARD
        // ------------------------------------------------------

        Container(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (_isGettingLocation)
                          const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Getting your location...',
                                style: TextStyle(
                                  color:
                                      Colors.black54,
                                ),
                              ),
                            ],
                          )
                        else if (_currentLocation !=
                            null)
                          Text(
                            _currentLocation!
                                .placeName,
                            style:
                                const TextStyle(
                              color:
                                  Colors.black54,
                              height: 1.4,
                            ),
                          )
                        else
                          const Text(
                            'Location unavailable',
                            style:
                                TextStyle(
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _isGettingLocation
                            ? null
                            : _loadCurrentLocation,
                    tooltip:
                        'Refresh location',
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                  ),
                ],
              ),

              if (_currentLocation !=
                  null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF6F8FC,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        size: 16,
                        color:
                            Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_currentLocation!.latitude.toStringAsFixed(6)}, '
                          '${_currentLocation!.longitude.toStringAsFixed(6)}',
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 26),

        // ------------------------------------------------------
        // SUBMIT BUTTON
        // ------------------------------------------------------

        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed:
                _isSubmitting
                    ? null
                    : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF1976D2),
              foregroundColor:
                  Colors.white,
              disabledBackgroundColor:
                  Colors.grey.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.send_rounded,
                  ),
            label: Text(
              _isSubmitting
                  ? 'Submitting...'
                  : 'Submit Report',
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 17,
                color: Colors.black45,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please submit only genuine incidents and provide accurate information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFF1976D2),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}