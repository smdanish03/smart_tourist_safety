import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IncidentManagementPage extends StatefulWidget {
  const IncidentManagementPage({super.key});

  @override
  State<IncidentManagementPage> createState() =>
      _IncidentManagementPageState();
}

class _IncidentManagementPageState
    extends State<IncidentManagementPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _loading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('incidents').get();

      final List<Map<String, dynamic>> incidents =
          snapshot.docs.map(
        (
          QueryDocumentSnapshot<Map<String, dynamic>>
              document,
        ) {
          final Map<String, dynamic> data =
              document.data();

          return {
            'documentId': document.id,
            ...data,
          };
        },
      ).toList();

      incidents.sort(
        (
          Map<String, dynamic> a,
          Map<String, dynamic> b,
        ) {
          final String dateA =
              a['createdAt']?.toString() ?? '';

          final String dateB =
              b['createdAt']?.toString() ?? '';

          return dateB.compareTo(dateA);
        },
      );

      if (!mounted) return;

      setState(() {
        _incidents = incidents;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'Could not load incident reports.';
      });
    }
  }

  String _getValue(
    Map<String, dynamic> incident,
    String field,
  ) {
    final dynamic value = incident[field];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Not available';
    }

    return value.toString();
  }

  String _getStatus(
    Map<String, dynamic> incident,
  ) {
    final String status =
        incident['status']?.toString() ?? '';

    if (status.isEmpty) {
      return 'Pending';
    }

    return status;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;

      case 'investigating':
        return Colors.orange;

      case 'rejected':
        return Colors.red;

      case 'pending':
      default:
        return Colors.blue;
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'accident':
        return Icons.car_crash;

      case 'theft':
        return Icons.wallet;

      case 'medical emergency':
        return Icons.medical_services;

      case 'harassment':
        return Icons.warning_amber;

      case 'lost person':
        return Icons.person_search;

      case 'lost item':
        return Icons.search;

      case 'crime':
        return Icons.local_police;

      case 'fire':
        return Icons.local_fire_department;

      default:
        return Icons.report_problem_outlined;
    }
  }

  String _formatDate(String value) {
    if (value == 'Not available') {
      return value;
    }

    try {
      final DateTime date =
          DateTime.parse(value).toLocal();

      final String day =
          date.day.toString().padLeft(2, '0');

      final String month =
          date.month.toString().padLeft(2, '0');

      final String year =
          date.year.toString();

      final String hour =
          date.hour.toString().padLeft(2, '0');

      final String minute =
          date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year  $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  Future<void> _updateIncidentStatus({
    required String documentId,
    required String newStatus,
  }) async {
    try {
      await _firestore
          .collection('incidents')
          .doc(documentId)
          .update({
        'status': newStatus,
        'statusUpdatedAt':
            DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      setState(() {
        final int index = _incidents.indexWhere(
          (Map<String, dynamic> incident) =>
              incident['documentId'] == documentId,
        );

        if (index != -1) {
          _incidents[index]['status'] =
              newStatus;

          _incidents[index]['statusUpdatedAt'] =
              DateTime.now().toIso8601String();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Incident status updated to $newStatus.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update status: ${error.message ?? 'Permission denied.'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update incident status.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showStatusDialog(
    Map<String, dynamic> incident,
  ) async {
    final String currentStatus =
        _getStatus(incident);

    final String documentId =
        _getValue(
      incident,
      'documentId',
    );

    final String reportId =
        _getValue(
      incident,
      'reportId',
    );

    const List<String> statuses = [
      'Pending',
      'Investigating',
      'Resolved',
      'Rejected',
    ];

    final String? selectedStatus =
        await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Update Incident Status',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reportId,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ...statuses.map(
                (String status) {
                  final bool selected =
                      status.toLowerCase() ==
                          currentStatus.toLowerCase();

                  final Color color =
                      _getStatusColor(status);

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            color.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          status == 'Pending'
                              ? Icons.pending_actions
                              : status ==
                                      'Investigating'
                                  ? Icons.search
                                  : status ==
                                          'Resolved'
                                      ? Icons
                                          .check_circle
                                      : Icons
                                          .cancel,
                          color: color,
                        ),
                      ),
                      title: Text(
                        status,
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: color,
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: color,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(
                          context,
                          status,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedStatus == null ||
        selectedStatus == currentStatus) {
      return;
    }

    await _updateIncidentStatus(
      documentId: documentId,
      newStatus: selectedStatus,
    );
  }

  Future<void> _showIncidentDetails(
    Map<String, dynamic> incident,
  ) async {
    final String incidentId =
        _getValue(incident, 'reportId');

    final String touristId =
        _getValue(incident, 'touristId');

    final String type =
        _getValue(incident, 'incidentType');

    final String description =
        _getValue(incident, 'description');

    final String locationName =
        _getValue(incident, 'locationName');

    final String latitude =
        _getValue(incident, 'latitude');

    final String longitude =
        _getValue(incident, 'longitude');

    final String createdAt =
        _formatDate(
      _getValue(incident, 'createdAt'),
    );

    final String status =
        _getStatus(incident);

    final Color statusColor =
        _getStatusColor(status);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.report_problem,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Incident Details',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _DetailItem(
                  title: 'Report ID',
                  value: incidentId,
                ),
                _DetailItem(
                  title: 'Tourist ID',
                  value: touristId,
                ),
                _DetailItem(
                  title: 'Incident Type',
                  value: type,
                ),
                _DetailItem(
                  title: 'Description',
                  value: description,
                ),
                _DetailItem(
                  title: 'Location',
                  value: locationName,
                ),
                _DetailItem(
                  title: 'Latitude',
                  value: latitude,
                ),
                _DetailItem(
                  title: 'Longitude',
                  value: longitude,
                ),
                _DetailItem(
                  title: 'Reported At',
                  value: createdAt,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showStatusDialog(incident);
              },
              icon: const Icon(
                Icons.edit_outlined,
              ),
              label: const Text(
                'Update Status',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Incident Management',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadIncidents,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadIncidents,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_incidents.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadIncidents,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.assignment_outlined,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No incident reports found.',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadIncidents,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(
                      Icons.assignment,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incident Reports',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_incidents.length} report${_incidents.length == 1 ? '' : 's'} submitted',
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._incidents.map(
            (
              Map<String, dynamic> incident,
            ) {
              final String incidentId =
                  _getValue(
                incident,
                'reportId',
              );

              final String type =
                  _getValue(
                incident,
                'incidentType',
              );

              final String description =
                  _getValue(
                incident,
                'description',
              );

              final String touristId =
                  _getValue(
                incident,
                'touristId',
              );

              final String location =
                  _getValue(
                incident,
                'locationName',
              );

              final String createdAt =
                  _formatDate(
                _getValue(
                  incident,
                  'createdAt',
                ),
              );

              final String status =
                  _getStatus(incident);

              final Color statusColor =
                  _getStatusColor(status);

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(12),
                  onTap: () =>
                      _showIncidentDetails(
                    incident,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              child: Icon(
                                _getIncidentIcon(
                                  type,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    type,
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
                                    incidentId,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors
                                          .grey
                                          .shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: statusColor
                                    .withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color:
                                      statusColor,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          description,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          icon: Icons.badge_outlined,
                          text:
                              'Tourist: $touristId',
                        ),
                        _SummaryRow(
                          icon:
                              Icons.location_on_outlined,
                          text:
                              'Location: $location',
                        ),
                        _SummaryRow(
                          icon: Icons.access_time,
                          text:
                              'Reported: $createdAt',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _showStatusDialog(
                                incident,
                              ),
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 19,
                              ),
                              label: const Text(
                                'Status',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _showIncidentDetails(
                                incident,
                              ),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 19,
                              ),
                              label: const Text(
                                'Details',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const _DetailItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}