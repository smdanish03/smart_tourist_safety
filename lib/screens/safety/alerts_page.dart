import 'package:flutter/material.dart';

import '../../models/alert.dart';
import '../../services/alert_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() =>
      _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final AlertService _alertService =
      AlertService();

  List<SafetyAlert> _alerts = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<SafetyAlert> alerts =
          await _alertService.getActiveAlerts();

      if (!mounted) return;

      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load safety alerts.';
      });
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.warning_rounded;
      case 'high':
        return Icons.error_rounded;
      case 'medium':
        return Icons.warning_amber_rounded;
      case 'low':
        return Icons.info_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'Immediate attention required';
      case 'high':
        return 'High safety concern';
      case 'medium':
        return 'Exercise additional caution';
      case 'low':
        return 'Stay aware of your surroundings';
      default:
        return 'Please stay alert';
    }
  }

  Widget _buildAlertCard(
    SafetyAlert alert,
  ) {
    final Color severityColor =
        _getSeverityColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              severityColor.withValues(
            alpha: 0.15,
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        severityColor.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSeverityIcon(
                      alert.severity,
                    ),
                    color: severityColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  severityColor
                                      .withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              alert.severity
                                  .toUpperCase(),
                              style: TextStyle(
                                color:
                                    severityColor,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing:
                                    0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getSeverityDescription(
                                alert.severity,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color:
                                    Colors.black45,
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

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF7F9FC),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                alert.message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    alert.locationName,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(
                    alert.createdAt,
                  ),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final String day =
        dateTime.day
            .toString()
            .padLeft(2, '0');

    final String month =
        dateTime.month
            .toString()
            .padLeft(2, '0');

    final String year =
        dateTime.year.toString();

    final String hour =
        dateTime.hour
            .toString()
            .padLeft(2, '0');

    final String minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey
                      .withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 34,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _errorMessage!,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadAlerts,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Try Again',
                ),
                style:
                    ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(140, 46),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_alerts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAlerts,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Container(
              width: 86,
              height: 86,
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 145,
              ),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 46,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Active Safety Alerts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Text(
                'There are currently no active safety alerts for tourists.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pull down to refresh',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          30,
        ),
        children: [
          // ----------------------------------------------------
          // ALERT SUMMARY
          // ----------------------------------------------------

          Container(
            padding:
                const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Color(0xFFEAF3FF),
                  Colors.white,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color:
                    const Color(0xFF1976D2)
                        .withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF1976D2,
                    ).withValues(
                      alpha: 0.10,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons.shield_outlined,
                    color:
                        Color(0xFF1976D2),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        '${_alerts.length} active safety '
                        '${_alerts.length == 1 ? 'alert' : 'alerts'}',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        'Stay informed and follow safety guidance while travelling.',
                        style:
                            TextStyle(
                          fontSize: 12,
                          color:
                              Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------------
          // ALERT LIST
          // ----------------------------------------------------

          ..._alerts.map(
            _buildAlertCard,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
        title: const Text(
          'Safety Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _isLoading
                    ? null
                    : _loadAlerts,
            tooltip:
                'Refresh alerts',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}