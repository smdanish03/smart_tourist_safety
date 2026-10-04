import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/admin_service.dart';
import '../auth/login_page.dart';
import 'incident_management_page.dart';
import 'tourist_list_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _alertSearchController =
      TextEditingController();

  bool _loading = true;
  bool _isAdmin = false;
  bool _savingAlert = false;

  int _totalTourists = 0;
  int _totalIncidents = 0;
  int _activeAlerts = 0;
  int _totalAlerts = 0;
  int _activeSOS = 0;
  int _pendingIncidents = 0;
  int _resolvedIncidents = 0;

  List<Map<String, dynamic>> _recentIncidents = [];
  List<Map<String, dynamic>> _sosReports = [];
  List<Map<String, dynamic>> _allAlerts = [];

  String _alertSeverityFilter = 'All';
  String? _errorMessage;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _incidentSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _alertSubscription;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _incidentSubscription?.cancel();
    _alertSubscription?.cancel();
    _alertSearchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final bool isAdmin = await _adminService.isCurrentUserAdmin();

      if (!isAdmin) {
        if (!mounted) return;
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> touristsSnapshot =
          await _firestore.collection('tourists').get();

      final QuerySnapshot<Map<String, dynamic>> incidentsSnapshot =
          await _firestore.collection('incidents').get();

      final QuerySnapshot<Map<String, dynamic>> alertsSnapshot =
          await _firestore.collection('alerts').get();

      final List<Map<String, dynamic>> incidents = incidentsSnapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> document) => {
              'id': document.id,
              ...document.data(),
            },
          )
          .toList();

      incidents.sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            _parseDate(b['createdAt']).compareTo(_parseDate(a['createdAt'])),
      );

      final List<Map<String, dynamic>> sosReports = incidents.where(
        (Map<String, dynamic> incident) {
          return incident['incidentType']?.toString().toLowerCase() ==
              'sos emergency';
        },
      ).toList();

      final List<Map<String, dynamic>> activeSOSReports = sosReports.where(
        (Map<String, dynamic> sos) {
          final String status =
              sos['status']?.toString().toLowerCase() ?? 'submitted';
          return status != 'resolved' && status != 'rejected';
        },
      ).toList();

      final List<Map<String, dynamic>> alerts = alertsSnapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> document) => {
              'id': document.id,
              ...document.data(),
            },
          )
          .toList();

      alerts.sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            _parseDate(b['createdAt']).compareTo(_parseDate(a['createdAt'])),
      );

      final int resolved = incidents.where((Map<String, dynamic> incident) {
        final String status =
            incident['status']?.toString().toLowerCase() ?? 'submitted';
        return status == 'resolved' || status == 'rejected';
      }).length;

      if (!mounted) return;

      setState(() {
        _isAdmin = true;
        _totalTourists = touristsSnapshot.docs.length;
        _totalIncidents = incidents.length;
        _activeAlerts = alerts
            .where((Map<String, dynamic> alert) => alert['active'] == true)
            .length;
        _totalAlerts = alerts.length;
        _activeSOS = activeSOSReports.length;
        _pendingIncidents = incidents.length - resolved;
        _resolvedIncidents = resolved;
        _recentIncidents = incidents.take(5).toList();
        _sosReports = activeSOSReports;
        _allAlerts = alerts;
        _loading = false;
      });

      _startRealtimeIncidentListener();
      _startRealtimeAlertListener();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Could not load dashboard data.';
      });
    }
  }

  // ============================================================
  // REAL-TIME INCIDENTS
  // ============================================================

  void _startRealtimeIncidentListener() {
    _incidentSubscription?.cancel();

    _incidentSubscription = _firestore
        .collection('incidents')
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final List<Map<String, dynamic>> incidents = snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> document) => {
                'id': document.id,
                ...document.data(),
              },
            )
            .toList();

        incidents.sort(
          (Map<String, dynamic> a, Map<String, dynamic> b) =>
              _parseDate(b['createdAt'])
                  .compareTo(_parseDate(a['createdAt'])),
        );

        final List<Map<String, dynamic>> sosReports = incidents.where(
          (Map<String, dynamic> incident) {
            return incident['incidentType']?.toString().toLowerCase() ==
                'sos emergency';
          },
        ).toList();

        final List<Map<String, dynamic>> activeSOSReports = sosReports.where(
          (Map<String, dynamic> sos) {
            final String status =
                sos['status']?.toString().toLowerCase() ?? 'submitted';
            return status != 'resolved' && status != 'rejected';
          },
        ).toList();

        final int resolved = incidents.where((Map<String, dynamic> incident) {
          final String status =
              incident['status']?.toString().toLowerCase() ?? 'submitted';
          return status == 'resolved' || status == 'rejected';
        }).length;

        if (!mounted) return;

        setState(() {
          _totalIncidents = incidents.length;
          _recentIncidents = incidents.take(5).toList();
          _sosReports = activeSOSReports;
          _activeSOS = activeSOSReports.length;
          _resolvedIncidents = resolved;
          _pendingIncidents = incidents.length - resolved;
        });
      },
      onError: (_) {},
    );
  }

  // ============================================================
  // REAL-TIME ALERTS
  // ============================================================

  void _startRealtimeAlertListener() {
    _alertSubscription?.cancel();

    _alertSubscription = _firestore.collection('alerts').snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final List<Map<String, dynamic>> alerts = snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> document) => {
                'id': document.id,
                ...document.data(),
              },
            )
            .toList();

        alerts.sort(
          (Map<String, dynamic> a, Map<String, dynamic> b) =>
              _parseDate(b['createdAt'])
                  .compareTo(_parseDate(a['createdAt'])),
        );

        if (!mounted) return;

        setState(() {
          _allAlerts = alerts;
          _totalAlerts = alerts.length;
          _activeAlerts = alerts
              .where((Map<String, dynamic> alert) => alert['active'] == true)
              .length;
        });
      },
      onError: (_) {},
    );
  }

  // ============================================================
  // ALERT MANAGEMENT
  // ============================================================

  Future<void> _showAlertEditor({Map<String, dynamic>? alert}) async {
    final TextEditingController titleController = TextEditingController(
      text: alert?['title']?.toString() ?? '',
    );
    final TextEditingController descriptionController =
        TextEditingController(
      text: alert?['description']?.toString() ?? '',
    );
    final TextEditingController locationController =
        TextEditingController(
      text: (alert?['location'] ?? alert?['locationName'])?.toString() ?? '',
    );

    String severity = alert?['severity']?.toString() ?? 'Medium';
    const List<String> severities = ['Low', 'Medium', 'High', 'Critical'];

    String type =
        (alert?['type'] ?? alert?['alertType'])?.toString() ??
            'General Safety';
    const List<String> types = [
      'General Safety',
      'Weather',
      'Security',
      'Traffic',
      'Crowd',
      'Emergency',
      'Other',
    ];

    if (!types.contains(type)) type = 'Other';

    bool active = alert == null ? true : alert['active'] == true;

    final Map<String, dynamic>? result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    alert == null
                        ? Icons.add_alert
                        : Icons.edit_notifications,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alert == null
                          ? 'Create Safety Alert'
                          : 'Edit Safety Alert',
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Alert Title *',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description_outlined),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location / Area',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                       initialValue:  severity,
                        decoration: const InputDecoration(
                          labelText: 'Severity',
                          prefixIcon: Icon(Icons.priority_high),
                          border: OutlineInputBorder(),
                        ),
                        items: severities.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => severity = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                       initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Alert Type',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: types.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 6),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Alert is active'),
                        subtitle: const Text(
                          'Active alerts are shown to tourists and used by AI risk analysis.',
                        ),
                        value: active,
                        onChanged: (value) {
                          setDialogState(() => active = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final String title = titleController.text.trim();
                    final String description =
                        descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter both title and description.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      {
                        'title': title,
                        'description': description,
                        'location': locationController.text.trim(),
                        'severity': severity,
                        'type': type,
                        'active': active,
                      },
                    );
                  },
                  icon: Icon(alert == null ? Icons.add_alert : Icons.save),
                  label: Text(
                    alert == null ? 'Create Alert' : 'Save Changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();

    if (result == null || !mounted || _savingAlert) return;

    setState(() => _savingAlert = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final Map<String, dynamic> data = {
        'title': result['title'],
        'description': result['description'],
        'location': result['location'],
        'severity': result['severity'],
        'type': result['type'],
        'active': result['active'] == true,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user?.uid,
      };

      if (alert == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = user?.uid;
        await _firestore.collection('alerts').add(data);
      } else {
        await _firestore
            .collection('alerts')
            .doc(alert['id'].toString())
            .update(data);
      }

      if (!mounted) return;
      _showMessage(
        alert == null
            ? 'Safety alert created successfully.'
            : 'Safety alert updated successfully.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to save alert: $error', isError: true);
    } finally {
      if (mounted) setState(() => _savingAlert = false);
    }
  }

  Future<void> _toggleAlert(Map<String, dynamic> alert) async {
    final String id = alert['id']?.toString() ?? '';
    if (id.isEmpty) return;

    final bool currentActive = alert['active'] == true;

    try {
      await _firestore.collection('alerts').doc(id).update({
        'active': !currentActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
      });

      if (!mounted) return;
      _showMessage(
        currentActive ? 'Alert deactivated.' : 'Alert activated.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to update alert: $error', isError: true);
    }
  }

  Future<void> _deleteAlert(Map<String, dynamic> alert) async {
    final String id = alert['id']?.toString() ?? '';
    if (id.isEmpty) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Safety Alert?'),
          content: Text(
            'This will permanently delete "${alert['title']?.toString() ?? 'this alert'}".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('alerts').doc(id).delete();

      if (!mounted) return;
      _showMessage('Safety alert deleted successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to delete alert: $error', isError: true);
    }
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    final String query =
        _alertSearchController.text.trim().toLowerCase();

    return _allAlerts.where((Map<String, dynamic> alert) {
      final String severity = alert['severity']?.toString() ?? '';

      if (_alertSeverityFilter != 'All' &&
          severity.toLowerCase() != _alertSeverityFilter.toLowerCase()) {
        return false;
      }

      if (query.isEmpty) return true;

      final String title =
          alert['title']?.toString().toLowerCase() ?? '';
      final String description =
          alert['description']?.toString().toLowerCase() ?? '';
      final String location =
          (alert['location'] ?? alert['locationName'])
                  ?.toString()
                  .toLowerCase() ??
              '';
      final String type =
          (alert['type'] ?? alert['alertType'])
                  ?.toString()
                  .toLowerCase() ??
              '';

      return title.contains(query) ||
          description.contains(query) ||
          location.contains(query) ||
          type.contains(query);
    }).toList();
  }

  Color _alertSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.deepPurple;
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final String title =
        alert['title']?.toString() ?? 'Untitled Alert';
    final String description =
        alert['description']?.toString() ?? 'No description available.';
    final String severity =
        alert['severity']?.toString() ?? 'Medium';
    final String type =
        (alert['type'] ?? alert['alertType'])?.toString() ??
            'General Safety';
    final String location =
        (alert['location'] ?? alert['locationName'])?.toString() ??
            'All areas';
    final bool active = alert['active'] == true;
    final Color severityColor = _alertSeverityColor(severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: severityColor,
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _StatusChip(
                            label: severity,
                            color: severityColor,
                          ),
                          _StatusChip(
                            label: type,
                            color: Colors.blue,
                          ),
                          _StatusChip(
                            label: active ? 'ACTIVE' : 'INACTIVE',
                            color: active ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'edit') {
                      _showAlertEditor(alert: alert);
                    } else if (value == 'toggle') {
                      _toggleAlert(alert);
                    } else if (value == 'delete') {
                      _deleteAlert(alert);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'toggle',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.power_settings_new),
                        title: Text(active ? 'Deactivate' : 'Activate'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.45),
            ),
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.location_on_outlined,
              label: 'Area',
              value: location,
            ),
            _InfoLine(
              icon: Icons.access_time,
              label: 'Created',
              value: _formatDate(alert['createdAt']),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openTouristList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TouristListPage(),
      ),
    );
  }

  void _openIncidentManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IncidentManagementPage(),
      ),
    );
  }

  // ============================================================
  // SOS LOCATION
  // ============================================================

  Future<void> _openSOSLocation(Map<String, dynamic> sos) async {
    final dynamic latitude = sos['latitude'];
    final dynamic longitude = sos['longitude'];

    if (latitude == null || longitude == null) {
      if (!mounted) return;
      _showMessage('SOS location is not available.', isError: true);
      return;
    }

    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(
          mapsUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;
        _showMessage('Unable to open Google Maps.', isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to open Google Maps.', isError: true);
    }
  }

  // ============================================================
  // UPDATE SOS STATUS
  // ============================================================

  Future<void> _updateSOSStatus(
    Map<String, dynamic> sos,
    String newStatus,
  ) async {
    final String documentId = sos['id']?.toString() ?? '';
    if (documentId.isEmpty) return;

    try {
      await _firestore
          .collection('incidents')
          .doc(documentId)
          .update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showMessage('SOS status updated to $newStatus.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Unable to update SOS status: $error',
        isError: true,
      );
    }
  }

  // ============================================================
  // SOS DETAILS
  // ============================================================

  void _showSOSDetails(Map<String, dynamic> sos) {
    final String touristName =
        sos['touristName']?.toString() ?? 'Unknown Tourist';
    final String touristId =
        sos['touristId']?.toString() ?? 'Unknown';
    final String email = sos['email']?.toString() ?? 'Not available';
    final String phone = sos['phone']?.toString() ?? 'Not available';
    final String city = sos['city']?.toString() ?? 'Not available';
    final String location =
        sos['locationName']?.toString() ?? 'Location unavailable';
    final String description =
        sos['description']?.toString() ?? 'No description';
    final String status = sos['status']?.toString() ?? 'Submitted';
    final String reportId =
        sos['reportId']?.toString() ?? sos['id']?.toString() ?? 'Unknown';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.sos, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SOS Emergency Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Report ID', value: reportId),
                _DetailRow(label: 'Tourist ID', value: touristId),
                _DetailRow(label: 'Name', value: touristName),
                _DetailRow(label: 'Email', value: email),
                _DetailRow(label: 'Phone', value: phone),
                _DetailRow(label: 'City', value: city),
                _DetailRow(label: 'Location', value: location),
                _DetailRow(label: 'Status', value: status),
                _DetailRow(
                  label: 'Time',
                  value: _formatDate(sos['createdAt']),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(description),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (sos['latitude'] != null && sos['longitude'] != null)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openSOSLocation(sos);
                },
                icon: const Icon(Icons.map),
                label: const Text('Map'),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(dynamic value) {
    final DateTime date = _parseDate(value);
    if (date.millisecondsSinceEpoch == 0) return 'Date unavailable';

    String two(int number) => number.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  Color _incidentColor(String type) {
    switch (type.toLowerCase()) {
      case 'theft':
        return Colors.red;
      case 'medical emergency':
        return Colors.orange;
      case 'harassment':
        return Colors.purple;
      case 'lost':
      case 'lost person':
        return Colors.blue;
      case 'accident':
        return Colors.deepOrange;
      case 'sos emergency':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 70,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Admin Access Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This account does not have permission to access the admin dashboard.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadDashboard,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Tourist Safety',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administrator Control Center',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.people,
                    title: 'Tourists',
                    value: _totalTourists.toString(),
                    iconColor: Colors.blue,
                    onTap: _openTouristList,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.report_problem,
                    title: 'Incidents',
                    value: _totalIncidents.toString(),
                    iconColor: Colors.orange,
                    onTap: _openIncidentManagement,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.warning_amber,
                    title: 'Active Alerts',
                    value: _activeAlerts.toString(),
                    iconColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.sos,
                    title: 'Active SOS',
                    value: _activeSOS.toString(),
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.pending_actions,
                    title: 'Pending Incidents',
                    value: _pendingIncidents.toString(),
                    iconColor: Colors.deepOrange,
                    onTap: _openIncidentManagement,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.check_circle_outline,
                    title: 'Resolved Incidents',
                    value: _resolvedIncidents.toString(),
                    iconColor: Colors.green,
                    onTap: _openIncidentManagement,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DashboardStatCard(
              icon: Icons.notifications_active_outlined,
              title: 'All Safety Alerts',
              value: _totalAlerts.toString(),
              iconColor: Colors.indigo,
            ),
            const SizedBox(height: 28),
            const Text(
              'Quick Management',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.people_outline),
                    ),
                    title: const Text('Manage Tourists'),
                    subtitle: const Text(
                      'View and manage tourist accounts',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openTouristList,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.assignment_outlined),
                    ),
                    title: const Text('Manage Incidents'),
                    subtitle: const Text(
                      'Review and resolve incident reports',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openIncidentManagement,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.add_alert),
                    ),
                    title: const Text('Create Safety Alert'),
                    subtitle: const Text(
                      'Publish a warning for tourists',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _savingAlert ? null : () => _showAlertEditor(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Safety Alert Management',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _savingAlert
                      ? null
                      : () => _showAlertEditor(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Alert'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _alertSearchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Search alerts',
                        hintText: 'Title, area, type or description',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _alertSearchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _alertSearchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                     initialValue:_alertSeverityFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by severity',
                        prefixIcon: Icon(Icons.filter_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All Severities'),
                        ),
                        DropdownMenuItem(
                          value: 'Critical',
                          child: Text('Critical'),
                        ),
                        DropdownMenuItem(
                          value: 'High',
                          child: Text('High'),
                        ),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: 'Low',
                          child: Text('Low'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _alertSeverityFilter = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_filteredAlerts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 52,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No safety alerts found.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Create an alert to notify tourists about important safety conditions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._filteredAlerts.map(_buildAlertCard),
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.sos, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Active SOS Emergencies',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_activeSOS > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_activeSOS ACTIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_sosReports.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 50,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No active SOS emergencies.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'New SOS reports will appear here automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._sosReports.map(_buildSOSCard),
            const SizedBox(height: 28),
            const Text(
              'Recent Incidents',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_recentIncidents.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 50,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 12),
                      const Text('No incident reports found.'),
                    ],
                  ),
                ),
              )
            else
              ..._recentIncidents.map(_buildRecentIncidentCard),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIncidentCard(Map<String, dynamic> incident) {
    final String type = incident['incidentType']?.toString() ?? 'Other';
    final String description =
        incident['description']?.toString() ?? 'No description';
    final String location =
        incident['locationName']?.toString() ?? 'Location unavailable';
    final String status = incident['status']?.toString() ?? 'Submitted';
    final Color color = _incidentColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(Icons.report_problem, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(
                  label: status,
                  color: status.toLowerCase() == 'resolved'
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: location,
            ),
            _InfoLine(
              icon: Icons.access_time,
              label: 'Time',
              value: _formatDate(incident['createdAt']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSCard(Map<String, dynamic> sos) {
    final String touristName =
        sos['touristName']?.toString() ?? 'Unknown Tourist';
    final String touristId =
        sos['touristId']?.toString() ?? 'Unknown ID';
    final String phone = sos['phone']?.toString() ?? 'Phone unavailable';
    final String location =
        sos['locationName']?.toString() ?? 'Location unavailable';
    final String status = sos['status']?.toString() ?? 'Submitted';
    final Color statusColor =
        status.toLowerCase() == 'investigating'
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.red.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sos,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SOS EMERGENCY',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(sos['createdAt']),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: status,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoLine(
              icon: Icons.person,
              label: 'Tourist',
              value: touristName,
            ),
            _InfoLine(
              icon: Icons.badge_outlined,
              label: 'Tourist ID',
              value: touristId,
            ),
            _InfoLine(
              icon: Icons.phone,
              label: 'Phone',
              value: phone,
            ),
            _InfoLine(
              icon: Icons.location_on,
              label: 'Location',
              value: location,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSOSDetails(sos),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openSOSLocation(sos),
                    icon: const Icon(Icons.map),
                    label: const Text('Map'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _updateSOSStatus(sos, 'Investigating'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Investigate'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateSOSStatus(sos, 'Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final VoidCallback? onTap;

  const _DashboardStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withValues(alpha: 0.12),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
