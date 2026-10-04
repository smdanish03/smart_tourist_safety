import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  String _touristId = '';
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _city = '';

  int _visitedPlacesCount = 0;
  int _reportsCount = 0;
  int _sosCount = 0;

  List<Map<String, dynamic>> _visitedPlaces =
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> _incidentReports =
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> _sosHistory =
      <Map<String, dynamic>>[];

  DocumentReference<Map<String, dynamic>>? _profileRef;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // FIND TOURIST PROFILE
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>?>
      _findTouristProfile(User user) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query =
          await _firestore
              .collection('tourists')
              .where('uid', isEqualTo: user.uid)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
    } catch (e) {
      debugPrint(
        'Tourist UID lookup error: $e',
      );
    }

    // Fallback using email-derived tourist ID.
    try {
      final String? authEmail = user.email;

      if (authEmail != null &&
          authEmail.contains('@')) {
        final String possibleTouristId =
            authEmail
                .split('@')
                .first
                .trim()
                .toUpperCase();

        if (RegExp(
          r'^[A-Z0-9]{5}$',
        ).hasMatch(possibleTouristId)) {
          final DocumentSnapshot<
                  Map<String, dynamic>>
              document =
              await _firestore
                  .collection('tourists')
                  .doc(possibleTouristId)
                  .get();

          if (document.exists) {
            return document;
          }
        }
      }
    } catch (e) {
      debugPrint(
        'Tourist ID fallback lookup error: $e',
      );
    }

    return null;
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final DocumentSnapshot<
              Map<String, dynamic>>?
          document =
          await _findTouristProfile(user);

      if (!mounted) return;

      if (document == null ||
          !document.exists) {
        final String authEmail =
            user.email ?? '';

        String fallbackTouristId = '';

        if (authEmail.contains('@')) {
          final String possibleId =
              authEmail
                  .split('@')
                  .first
                  .trim()
                  .toUpperCase();

          if (RegExp(
            r'^[A-Z0-9]{5}$',
          ).hasMatch(possibleId)) {
            fallbackTouristId = possibleId;

            _profileRef = _firestore
                .collection('tourists')
                .doc(fallbackTouristId);
          }
        }

        setState(() {
          _touristId = fallbackTouristId;
          _fullName =
              (user.displayName ?? '').trim();
          _email = authEmail;
          _phone = '';
          _city = '';
          _isLoading = false;
        });

        await _loadStatistics(
          fallbackTouristId,
        );

        return;
      }

      final Map<String, dynamic> data =
          document.data() ??
              <String, dynamic>{};

      final String documentTouristId =
          document.id.trim().toUpperCase();

      final String loadedTouristId =
          data['touristId']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true
              ? data['touristId']
                  .toString()
                  .trim()
                  .toUpperCase()
              : documentTouristId;

      final String loadedName =
          data['fullName']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true
              ? data['fullName']
                  .toString()
                  .trim()
              : data['name']
                          ?.toString()
                          .trim()
                          .isNotEmpty ==
                      true
                  ? data['name']
                      .toString()
                      .trim()
                  : (user.displayName ?? '')
                      .trim();

      final String loadedEmail =
          data['email']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true
              ? data['email']
                  .toString()
                  .trim()
              : '';

      final String loadedPhone =
          data['phone']
                  ?.toString()
                  .trim() ??
              '';

      final String loadedCity =
          data['city']
                  ?.toString()
                  .trim() ??
              '';

      _profileRef = document.reference;

      setState(() {
        _touristId = loadedTouristId;
        _fullName = loadedName;
        _email = loadedEmail.isNotEmpty
            ? loadedEmail
            : (user.email ?? '');
        _phone = loadedPhone;
        _city = loadedCity;
        _isLoading = false;
      });

      await _loadStatistics(
        document.id,
      );
    } catch (e) {
      debugPrint(
        'Profile load error: $e',
      );

      if (!mounted) return;

      final String authEmail =
          user.email ?? '';

      String fallbackTouristId = '';

      if (authEmail.contains('@')) {
        final String possibleId =
            authEmail
                .split('@')
                .first
                .trim()
                .toUpperCase();

        if (RegExp(
          r'^[A-Z0-9]{5}$',
        ).hasMatch(possibleId)) {
          fallbackTouristId = possibleId;

          _profileRef = _firestore
              .collection('tourists')
              .doc(fallbackTouristId);
        }
      }

      setState(() {
        _touristId = fallbackTouristId;
        _fullName =
            (user.displayName ?? '').trim();
        _email = authEmail;
        _phone = '';
        _city = '';
        _isLoading = false;
      });

      await _loadStatistics(
        fallbackTouristId,
      );
    }
  }

  // ============================================================
  // LOAD ALL TRAVEL STATISTICS
  // ============================================================

  Future<void> _loadStatistics(
    String touristId,
  ) async {
    if (touristId.trim().isEmpty) {
      return;
    }

    int visitedCount = 0;
    int reportsCount = 0;

    List<Map<String, dynamic>> visitedPlaces =
        <Map<String, dynamic>>[];

    List<Map<String, dynamic>> incidentReports =
        <Map<String, dynamic>>[];

    List<Map<String, dynamic>> sosHistory =
        <Map<String, dynamic>>[];

    // ==========================================================
    // VISITED PLACES
    // ==========================================================

    try {
      final QuerySnapshot<
              Map<String, dynamic>>
          visitedSnapshot =
          await _firestore
              .collection('tourists')
              .doc(touristId)
              .collection('visitedPlaces')
              .get();

      visitedCount =
          visitedSnapshot.docs.length;

      visitedPlaces =
          visitedSnapshot.docs
              .map(
                (
                  QueryDocumentSnapshot<
                          Map<String, dynamic>>
                      document,
                ) {
                  final Map<String, dynamic>
                      data =
                      document.data();

                  return <String, dynamic>{
                    'id': document.id,
                    ...data,
                  };
                },
              )
              .toList();

      visitedPlaces.sort(
        (
          Map<String, dynamic> a,
          Map<String, dynamic> b,
        ) {
          return _parseTimestamp(
            b['visitedAt'],
          ).compareTo(
            _parseTimestamp(
              a['visitedAt'],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Visited places load error: $e',
      );
    }

    // ==========================================================
    // INCIDENT REPORTS + SOS
    // ==========================================================

    try {
      final User? user =
          _auth.currentUser;

      if (user != null) {
        final QuerySnapshot<
                Map<String, dynamic>>
            incidents =
            await _firestore
                .collection('incidents')
                .where(
                  'uid',
                  isEqualTo: user.uid,
                )
                .get();

        // Keep all incidents.
        final List<Map<String, dynamic>>
            allIncidents =
            incidents.docs
                .map(
                  (
                    QueryDocumentSnapshot<
                            Map<String, dynamic>>
                        document,
                  ) {
                    final Map<String, dynamic>
                        data =
                        document.data();

                    return <String, dynamic>{
                      'id': document.id,
                      ...data,
                    };
                  },
                )
                .toList();

        // ------------------------------------------------------
        // SOS
        // ------------------------------------------------------

        sosHistory =
            allIncidents.where(
          (
            Map<String, dynamic> incident,
          ) {
            return (incident['incidentType']
                        ?.toString()
                        .trim()
                        .toLowerCase() ??
                    '') ==
                'sos emergency';
          },
        ).toList();

        // ------------------------------------------------------
        // NORMAL INCIDENT REPORTS
        // ------------------------------------------------------

        incidentReports =
            allIncidents.where(
          (
            Map<String, dynamic> incident,
          ) {
            return (incident['incidentType']
                        ?.toString()
                        .trim()
                        .toLowerCase() ??
                    '') !=
                'sos emergency';
          },
        ).toList();

        incidentReports.sort(
          (
            Map<String, dynamic> a,
            Map<String, dynamic> b,
          ) {
            return _parseTimestamp(
              b['createdAt'],
            ).compareTo(
              _parseTimestamp(
                a['createdAt'],
              ),
            );
          },
        );

        sosHistory.sort(
          (
            Map<String, dynamic> a,
            Map<String, dynamic> b,
          ) {
            return _parseTimestamp(
              b['createdAt'],
            ).compareTo(
              _parseTimestamp(
                a['createdAt'],
              ),
            );
          },
        );

        reportsCount =
            incidentReports.length;
      }
    } catch (e) {
      debugPrint(
        'Incident/SOS load error: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      _visitedPlacesCount =
          visitedCount;

      _visitedPlaces =
          visitedPlaces;

      _reportsCount =
          reportsCount;

      _incidentReports =
          incidentReports;

      _sosCount =
          sosHistory.length;

      _sosHistory =
          sosHistory;
    });
  }

  // ============================================================
  // TIMESTAMP
  // ============================================================

  DateTime _parseTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String &&
        value.trim().isNotEmpty) {
      return DateTime.tryParse(
            value.trim(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          );
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }

  String _formatDateTime(
    dynamic value,
  ) {
    final DateTime date =
        _parseTimestamp(value).toLocal();

    if (date.millisecondsSinceEpoch ==
        0) {
      return 'Time not available';
    }

    final String hour =
        (date.hour % 12 == 0
                ? 12
                : date.hour % 12)
            .toString();

    final String minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final String period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} $hour:$minute $period';
  }

  // ============================================================
  // SOS DURATION
  // ============================================================

  String _formatSosDuration(
    Map<String, dynamic> sos,
  ) {
    final DateTime start =
        _parseTimestamp(
      sos['createdAt'],
    );

    if (start.millisecondsSinceEpoch ==
        0) {
      return 'Duration not available';
    }

    final String status =
        sos['status']
                ?.toString()
                .trim()
                .toLowerCase() ??
            'submitted';

    final bool closed =
        status == 'resolved' ||
        status == 'rejected';

    final DateTime end =
        closed
            ? _parseTimestamp(
                sos['statusUpdatedAt'],
              )
            : DateTime.now();

    if (end.millisecondsSinceEpoch ==
            0 ||
        end.isBefore(start)) {
      return closed
          ? 'Duration not available'
          : 'Active now';
    }

    final Duration duration =
        end.difference(start);

    final int hours =
        duration.inHours;

    final int minutes =
        duration.inMinutes
            .remainder(60);

    if (hours > 0) {
      return '$hours hr $minutes min';
    }

    return '${minutes < 1 ? 1 : minutes} min';
  }

  // ============================================================
  // VISITED PLACE CARD
  // ============================================================

  Widget _buildVisitedPlaceCard(
    Map<String, dynamic> visited,
  ) {
    final String placeName =
        visited['placeName']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? visited['placeName']
                .toString()
                .trim()
            : 'Unknown Place';

    final String category =
        visited['category']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? visited['category']
                .toString()
                .trim()
            : 'Tourist Place';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.place,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(
                    color:
                        Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color:
                          Colors.green.shade700,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Visited: ${_formatDateTime(visited['visitedAt'])}',
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INCIDENT REPORT CARD
  // ============================================================

  Widget _buildIncidentReportCard(
    Map<String, dynamic> incident,
  ) {
    final String incidentType =
        incident['incidentType']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? incident['incidentType']
                .toString()
                .trim()
            : 'Incident Report';

    final String description =
        incident['description']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? incident['description']
                .toString()
                .trim()
            : incident['reason']
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true
                ? incident['reason']
                    .toString()
                    .trim()
                : incident['message']
                            ?.toString()
                            .trim()
                            .isNotEmpty ==
                        true
                    ? incident['message']
                        .toString()
                        .trim()
                    : incident['details']
                                ?.toString()
                                .trim()
                                .isNotEmpty ==
                            true
                        ? incident['details']
                            .toString()
                            .trim()
                        : 'No description available';

    final String location =
        incident['location']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? incident['location']
                .toString()
                .trim()
            : incident['placeName']
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true
                ? incident['placeName']
                    .toString()
                    .trim()
                : '';

    final String status =
        incident['status']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? incident['status']
                .toString()
                .trim()
            : 'Submitted';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.report_problem_outlined,
                  color:
                      Colors.orange.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  incidentType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors.orange.shade100,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Reported: ${_formatDateTime(incident['createdAt'])}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
            ),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ProfileSettingsPage(
          fullName: _fullName,
          email: _email,
          phone: _phone,
          city: _city,
          onEditProfile:
              _openEditProfile,
          onDeleteAccount:
              _confirmDeleteAccount,
        ),
      ),
    );

    if (!mounted) return;

    await _loadProfile();
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _openEditProfile() async {
    final TextEditingController
        nameController =
        TextEditingController(
      text: _fullName,
    );

    final TextEditingController
        emailController =
        TextEditingController(
      text: _email,
    );

    final TextEditingController
        phoneController =
        TextEditingController(
      text: _phone,
    );

    final TextEditingController
        cityController =
        TextEditingController(
      text: _city,
    );

    final GlobalKey<FormState>
        formKey =
        GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text('Edit Profile'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller:
                          nameController,
                      textCapitalization:
                          TextCapitalization
                              .words,
                      decoration:
                          const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter your name.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller:
                          emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      decoration:
                          const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final String email =
                            value?.trim() ??
                                '';

                        if (email.isEmpty) {
                          return 'Please enter your email.';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller:
                          phoneController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller:
                          cityController,
                      textCapitalization:
                          TextCapitalization
                              .words,
                      decoration:
                          const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(
                          Icons
                              .location_city_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (!formKey
                          .currentState!
                          .validate()) {
                        return;
                      }

                      await _saveProfile(
                        dialogContext,
                        nameController.text
                            .trim(),
                        emailController.text
                            .trim(),
                        phoneController.text
                            .trim(),
                        cityController.text
                            .trim(),
                      );
                    },
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                    ),
              label: const Text(
                'Save Changes',
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile(
    BuildContext dialogContext,
    String newName,
    String newEmail,
    String newPhone,
    String newCity,
  ) async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    final String touristId =
        _touristId.trim().toUpperCase();

    if (touristId.isEmpty) {
      _showMessage(
        'Tourist ID is not available. Please login again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String oldEmail =
          _email.trim();

      final String newEmailLower =
          newEmail.toLowerCase().trim();

      final DocumentReference<
              Map<String, dynamic>>
          profileRef =
          _profileRef ??
              _firestore
                  .collection('tourists')
                  .doc(touristId);

      final WriteBatch batch =
          _firestore.batch();

      batch.set(
        profileRef,
        <String, dynamic>{
          'uid': user.uid,
          'touristId': touristId,
          'fullName': newName,
          'name': newName,
          'email': newEmailLower,
          'phone': newPhone,
          'city': newCity,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (oldEmail.toLowerCase() !=
          newEmailLower) {
        final String oldKey =
            _emailKey(oldEmail);

        final String newKey =
            _emailKey(newEmailLower);

        if (oldKey.isNotEmpty) {
          batch.delete(
            _firestore
                .collection('emailIndex')
                .doc(oldKey),
          );
        }

        if (newKey.isNotEmpty) {
          batch.set(
            _firestore
                .collection('emailIndex')
                .doc(newKey),
            <String, dynamic>{
              'emailKey': newKey,
              'email': newEmailLower,
              'uid': user.uid,
              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
          );
        }
      }

      await batch.commit();

      try {
        await user.updateDisplayName(
          newName,
        );
        await user.reload();
      } catch (e) {
        debugPrint(
          'Auth display name update error: $e',
        );
      }

      _profileRef = profileRef;

      if (!mounted) return;

      setState(() {
        _fullName = newName;
        _email = newEmailLower;
        _phone = newPhone;
        _city = newCity;
        _isSaving = false;
      });

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      _showMessage(
        'Profile updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Unable to update profile: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT CONFIRMATION
  // ============================================================

  Future<void>
      _confirmDeleteAccount() async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete Account Permanently?',
                ),
              ),
            ],
          ),
          content: const Text(
            'This will permanently delete your tourist profile, visited places, incident reports and account access.\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete Permanently',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _deleteAccount();
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount() async {
    if (_isDeleting) {
      return;
    }

    final User? user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    final String? password =
        await _askForPassword();

    if (password == null ||
        password.isEmpty) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final String? internalEmail =
          user.email;

      if (internalEmail == null ||
          internalEmail.isEmpty) {
        throw Exception(
          'Authentication email is not available.',
        );
      }

      final AuthCredential credential =
          EmailAuthProvider.credential(
        email: internalEmail,
        password: password,
      );

      await user
          .reauthenticateWithCredential(
        credential,
      );

      final DocumentSnapshot<
              Map<String, dynamic>>?
          profile =
          await _findTouristProfile(
        user,
      );

      String touristId =
          _touristId;

      if (profile != null &&
          profile.exists) {
        touristId =
            profile.id.toUpperCase();
      }

      if (touristId.isEmpty &&
          internalEmail.contains('@')) {
        touristId =
            internalEmail
                .split('@')
                .first
                .toUpperCase();
      }

      // --------------------------------------------------------
      // DELETE VISITED PLACES
      // --------------------------------------------------------

      if (touristId.isNotEmpty) {
        final QuerySnapshot<
                Map<String, dynamic>>
            visitedSnapshot =
            await _firestore
                .collection('tourists')
                .doc(touristId)
                .collection('visitedPlaces')
                .get();

        for (final QueryDocumentSnapshot<
                Map<String, dynamic>>
            document
            in visitedSnapshot.docs) {
          await document.reference.delete();
        }
      }

      // --------------------------------------------------------
      // DELETE INCIDENTS
      // --------------------------------------------------------

      final QuerySnapshot<
              Map<String, dynamic>>
          incidentSnapshot =
          await _firestore
              .collection('incidents')
              .where(
                'uid',
                isEqualTo: user.uid,
              )
              .get();

      for (final QueryDocumentSnapshot<
              Map<String, dynamic>>
          document
          in incidentSnapshot.docs) {
        await document.reference.delete();
      }

      // --------------------------------------------------------
      // DELETE EMAIL INDEX
      // --------------------------------------------------------

      final String email =
          _email.trim().isNotEmpty
              ? _email.trim()
              : internalEmail;

      final String emailKey =
          _emailKey(email);

      if (emailKey.isNotEmpty) {
        final DocumentReference<
                Map<String, dynamic>>
            emailIndexRef =
            _firestore
                .collection('emailIndex')
                .doc(emailKey);

        final DocumentSnapshot<
                Map<String, dynamic>>
            emailIndex =
            await emailIndexRef.get();

        if (emailIndex.exists) {
          await emailIndexRef.delete();
        }
      }

      // --------------------------------------------------------
      // DELETE TOURIST PROFILE
      // --------------------------------------------------------

      if (touristId.isNotEmpty) {
        final DocumentReference<
                Map<String, dynamic>>
            touristRef =
            _firestore
                .collection('tourists')
                .doc(touristId);

        final DocumentSnapshot<
                Map<String, dynamic>>
            touristDocument =
            await touristRef.get();

        if (touristDocument.exists) {
          await touristRef.delete();
        }
      }

      // --------------------------------------------------------
      // DELETE AUTH ACCOUNT
      // --------------------------------------------------------

      await user.delete();

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(
            successMessage:
                'Your account has been deleted successfully.',
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      String message =
          'Unable to delete account.';

      if (e.code ==
              'wrong-password' ||
          e.code ==
              'invalid-credential') {
        message =
            'Incorrect password. Account was not deleted.';
      } else if (e.code ==
          'requires-recent-login') {
        message =
            'Please login again and try deleting the account.';
      } else {
        message =
            e.message ??
                'Unable to delete account.';
      }

      _showMessage(
        message,
        isError: true,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showMessage(
        'Account deletion stopped: ${e.message ?? e.code}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showMessage(
        'Account deletion failed: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // PASSWORD DIALOG
  // ============================================================

  Future<String?> _askForPassword() async {
    final TextEditingController
        passwordController =
        TextEditingController();

    bool obscurePassword = true;

    final String? password =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Confirm Your Password',
                    ),
                  ),
                ],
              ),
              content: TextField(
                controller:
                    passwordController,
                obscureText:
                    obscurePassword,
                maxLength: 6,
                decoration:
                    InputDecoration(
                  labelText: 'Password',
                  hintText:
                      'Enter your 6-character password',
                  border:
                      const OutlineInputBorder(),
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setDialogState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      null,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () {
                    final String value =
                        passwordController
                            .text
                            .trim();

                    if (value.length !=
                        6) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must be exactly 6 characters.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      value,
                    );
                  },
                  child: const Text(
                    'Continue',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();

    return password;
  }

  // ============================================================
  // EMAIL KEY
  // ============================================================

  String _emailKey(
    String email,
  ) {
    return email.trim().toLowerCase();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red
              : Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final String displayName =
        _fullName.trim().isEmpty
            ? 'Name not available'
            : _fullName.trim();

    final String displayTouristId =
        _touristId.trim().isEmpty
            ? 'Not available'
            : _touristId.trim();

    final String displayEmail =
        _email.trim().isEmpty
            ? 'Not available'
            : _email.trim();

    final String displayPhone =
        _phone.trim().isEmpty
            ? 'Not added'
            : _phone.trim();

    final String displayCity =
        _city.trim().isEmpty
            ? 'Not added'
            : _city.trim();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PROFILE HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration:
                          const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color:
                            Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      displayName,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Tourist ID: $displayTouristId',
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.20,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child:
                          const Text(
                        'Account Active',
                        style:
                            TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // PERSONAL INFORMATION
              // ==================================================

              _ProfileSection(
                title:
                    'Personal Information',
                icon:
                    Icons.person_outline,
                children: [
                  _InfoRow(
                    icon:
                        Icons.badge_outlined,
                    label: 'Tourist ID',
                    value:
                        displayTouristId,
                  ),
                  _InfoRow(
                    icon:
                        Icons.person_outline,
                    label: 'Name',
                    value: displayName,
                  ),
                  _InfoRow(
                    icon:
                        Icons.email_outlined,
                    label: 'Email',
                    value: displayEmail,
                  ),
                  _InfoRow(
                    icon:
                        Icons.phone_outlined,
                    label: 'Phone',
                    value: displayPhone,
                  ),
                  _InfoRow(
                    icon: Icons
                        .location_city_outlined,
                    label: 'City',
                    value: displayCity,
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // MY TRAVEL
              // ==================================================

              _ProfileSection(
                title: 'My Travel',
                icon:
                    Icons.travel_explore,
                children: [
                  // ----------------------------------------------
                  // STATISTICS
                  // ----------------------------------------------

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 105,
                        child: _StatCard(
                          icon: Icons
                              .place_outlined,
                          title:
                              'Visited Places',
                          value:
                              '$_visitedPlacesCount',
                        ),
                      ),
                      SizedBox(
                        width: 105,
                        child: _StatCard(
                          icon: Icons
                              .report_problem_outlined,
                          title:
                              'Incident Reports',
                          value:
                              '$_reportsCount',
                        ),
                      ),
                      SizedBox(
                        width: 105,
                        child: _StatCard(
                          icon: Icons.sos,
                          title:
                              'SOS History',
                          value:
                              '$_sosCount',
                        ),
                      ),
                    ],
                  ),

                  // ==================================================
                  // VISITED PLACES
                  // ==================================================

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'Places You Have Visited',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_visitedPlaces
                          .isNotEmpty)
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .green
                                .shade50,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child: Text(
                            '${_visitedPlaces.length}',
                            style: TextStyle(
                              color: Colors
                                  .green
                                  .shade800,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (_visitedPlaces.isEmpty)
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(18),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade50,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                      child: Text(
                        'No visited places yet.',
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    )
                  else
                    ..._visitedPlaces.map(
                      (
                        Map<String, dynamic>
                            visited,
                      ) {
                        return _buildVisitedPlaceCard(
                          visited,
                        );
                      },
                    ),

                  // ==================================================
                  // INCIDENT REPORT HISTORY
                  // ==================================================

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .report_problem_outlined,
                        color:
                            Colors.orange,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'Incident Report History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_incidentReports
                          .isNotEmpty)
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .orange
                                .shade50,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child: Text(
                            '${_incidentReports.length}',
                            style: TextStyle(
                              color: Colors
                                  .orange
                                  .shade800,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (_incidentReports.isEmpty)
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(18),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade50,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                      child: Text(
                        'No incident reports available.',
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    )
                  else
                    ..._incidentReports.map(
                      (
                        Map<String, dynamic>
                            incident,
                      ) {
                        return _buildIncidentReportCard(
                          incident,
                        );
                      },
                    ),

                  // ==================================================
                  // SOS HISTORY
                  // ==================================================

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.sos,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'SOS Time History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_sosHistory
                          .isNotEmpty)
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .red
                                .shade50,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child: Text(
                            '${_sosHistory.length}',
                            style: TextStyle(
                              color: Colors
                                  .red
                                  .shade800,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (_sosHistory.isEmpty)
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(18),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade50,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                      child: Text(
                        'No SOS history available.',
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    )
                  else
                    ..._sosHistory.map(
                      (
                        Map<String, dynamic>
                            sos,
                      ) {
                        final String status =
                            sos['status']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ==
                                true
                            ? sos['status']
                                .toString()
                                .trim()
                            : 'Submitted';

                        final String
                            normalizedStatus =
                            status
                                .toLowerCase();

                        final bool active =
                            normalizedStatus !=
                                    'resolved' &&
                                normalizedStatus !=
                                    'rejected';

                        final String
                            sosReason =
                            sos['reason']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ==
                                    true
                                ? sos['reason']
                                    .toString()
                                    .trim()
                                : sos['description']
                                            ?.toString()
                                            .trim()
                                            .isNotEmpty ==
                                        true
                                    ? sos[
                                            'description']
                                        .toString()
                                        .trim()
                                    : sos['message']
                                                ?.toString()
                                                .trim()
                                                .isNotEmpty ==
                                            true
                                        ? sos[
                                                'message']
                                            .toString()
                                            .trim()
                                        : 'Emergency SOS activated';

                        final String
                            sosLocation =
                            sos['location']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ==
                                    true
                                ? sos['location']
                                    .toString()
                                    .trim()
                                : sos['placeName']
                                            ?.toString()
                                            .trim()
                                            .isNotEmpty ==
                                        true
                                    ? sos[
                                            'placeName']
                                        .toString()
                                        .trim()
                                    : '';

                        return Container(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),
                          padding:
                              const EdgeInsets
                                  .all(14),
                          decoration:
                              BoxDecoration(
                            color: active
                                ? Colors
                                    .red
                                    .shade50
                                : Colors
                                    .grey
                                    .shade50,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            border:
                                Border.all(
                              color: active
                                  ? Colors
                                      .red
                                      .shade200
                                  : Colors
                                      .grey
                                      .shade200,
                            ),
                          ),
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:
                                        44,
                                    height:
                                        44,
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .white,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                    child:
                                        Icon(
                                      Icons
                                          .sos,
                                      color: active
                                          ? Colors
                                              .red
                                          : Colors
                                              .grey
                                              .shade700,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    child:
                                        Text(
                                      'SOS Emergency',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            16,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          8,
                                      vertical:
                                          4,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: active
                                          ? Colors
                                              .red
                                              .shade100
                                          : Colors
                                              .green
                                              .shade100,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                    ),
                                    child:
                                        Text(
                                      active
                                          ? 'Active'
                                          : status,
                                      style:
                                          TextStyle(
                                        fontSize:
                                            11,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                        color: active
                                            ? Colors
                                                .red
                                                .shade800
                                            : Colors
                                                .green
                                                .shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                'Reason: $sosReason',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                  fontSize:
                                      13,
                                ),
                              ),

                              if (sosLocation
                                  .isNotEmpty) ...[
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Icon(
                                      Icons
                                          .location_on_outlined,
                                      size:
                                          17,
                                      color: Colors
                                          .grey
                                          .shade700,
                                    ),
                                    const SizedBox(
                                      width:
                                          5,
                                    ),
                                    Expanded(
                                      child:
                                          Text(
                                        sosLocation,
                                        style:
                                            TextStyle(
                                          color: Colors
                                              .grey
                                              .shade700,
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(
                                height: 7,
                              ),

                              Text(
                                'Activated: ${_formatDateTime(sos['createdAt'])}',
                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey
                                      .shade700,
                                  fontSize:
                                      13,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                active
                                    ? 'Active for: ${_formatSosDuration(sos)}'
                                    : 'Active duration: ${_formatSosDuration(sos)}',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // SETTINGS
              // ==================================================

              _ProfileSection(
                title: 'Settings',
                icon:
                    Icons.settings_outlined,
                children: [
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration:
                          BoxDecoration(
                        color: Colors.blue
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .settings_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    subtitle:
                        const Text(
                      'Edit profile or permanently delete your account',
                    ),
                    trailing:
                        const Icon(
                      Icons.chevron_right,
                    ),
                    onTap:
                        _openSettings,
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // LOGOUT
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child:
                    OutlinedButton.icon(
                  onPressed: _isDeleting
                      ? null
                      : _logout,
                  icon: const Icon(
                    Icons.logout,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// SETTINGS PAGE
// =================================================================

class _ProfileSettingsPage
    extends StatelessWidget {
  final String fullName;
  final String email;
  final String phone;
  final String city;

  final Future<void> Function()
      onEditProfile;

  final Future<void> Function()
      onDeleteAccount;

  const _ProfileSettingsPage({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.onEditProfile,
    required this.onDeleteAccount,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Colors.blue.shade50,
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          fullName.trim()
                                  .isEmpty
                              ? 'Name not available'
                              : fullName,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          email.isEmpty
                              ? 'Email not available'
                              : email,
                          style: TextStyle(
                            color: Colors
                                .grey
                                .shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Card(
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color: Colors.blue
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              subtitle:
                  const Text(
                'Change your name, email, phone and city',
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap:
                  onEditProfile,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Card(
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color: Colors.red
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .delete_forever_outlined,
                  color: Colors.red,
                ),
              ),
              title: const Text(
                'Delete Account Permanently',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              subtitle:
                  const Text(
                'Permanently delete your account and data',
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
                color: Colors.red,
              ),
              onTap:
                  onDeleteAccount,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Container(
            padding:
                const EdgeInsets.all(15),
            decoration:
                BoxDecoration(
              color: Colors.red
                  .withValues(
                alpha: 0.06,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: Colors.red
                    .withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    'Permanent account deletion cannot be undone. Your profile and associated account data will be removed.',
                    style: TextStyle(
                      height: 1.4,
                      fontSize: 13,
                    ),
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

// =================================================================
// PROFILE SECTION
// =================================================================

class _ProfileSection
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blue,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// =================================================================
// INFO ROW
// =================================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color:
                Colors.grey.shade600,
          ),
          const SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// STAT CARD
// =================================================================

class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 30,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            title,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}