import 'package:flutter/material.dart';

import '../../models/tourist_risk.dart';
import '../../services/alert_service.dart';
import '../../services/location_weather_service.dart';
import '../../services/risk_analysis_service.dart';

class RiskAnalysisPage extends StatefulWidget {
  const RiskAnalysisPage({super.key});

  @override
  State<RiskAnalysisPage> createState() => _RiskAnalysisPageState();
}

class _RiskAnalysisPageState extends State<RiskAnalysisPage> {
  final RiskAnalysisService _riskAnalysisService =
      RiskAnalysisService();

  final AlertService _alertService = AlertService();

  final LocationWeatherService _locationWeatherService =
      LocationWeatherService();

  TouristRisk? _risk;

  bool _isLoading = true;

  String? _errorMessage;

  double? _temperature;

  String _weatherDescription = '';

  bool _hasActiveAlert = false;

  @override
  void initState() {
    super.initState();
    _analyzeRealRisk();
  }

  Future<void> _analyzeRealRisk() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationWeatherData =
          await _locationWeatherService.getLocationAndWeather();

      final activeAlerts =
          await _alertService.getActiveAlerts();

      final double temperature =
          locationWeatherData.weather.temperature;

      final String locationName =
          locationWeatherData.location.placeName;

      final bool hasActiveAlert =
          activeAlerts.isNotEmpty;

      final TouristRisk result =
          _riskAnalysisService.analyzeRisk(
        locationName: locationName,
        temperature: temperature,
        activeSafetyAlert: hasActiveAlert,
        nearEmergencyArea: false,
      );

      if (!mounted) return;

      setState(() {
        _risk = result;
        _temperature = temperature;
        _weatherDescription =
            locationWeatherData.weather.description;
        _hasActiveAlert = hasActiveAlert;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to calculate live risk. Please check your location, internet connection, and try again.';
      });
    }
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getRiskIcon(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.warning_amber_rounded;
      default:
        return Icons.verified_user_rounded;
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
          'AI Risk Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _analyzeRealRisk,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Risk',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_risk == null) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _analyzeRealRisk,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          _buildIntroHeader(),

          const SizedBox(height: 18),

          _buildRiskSummaryCard(),

          const SizedBox(height: 16),

          _buildLiveConditionsCard(),

          const SizedBox(height: 16),

          _buildReasonsCard(),

          const SizedBox(height: 16),

          _buildRecommendationsCard(),

          const SizedBox(height: 16),

          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildIntroHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.psychology_outlined,
            color: Colors.deepPurple,
            size: 28,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tourist Safety Risk',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Live assessment based on your current conditions.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskSummaryCard() {
    final Color riskColor =
        _getRiskColor(_risk!.riskLevel);

    final IconData riskIcon =
        _getRiskIcon(_risk!.riskLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: riskColor.withValues(alpha: 0.18),
                width: 2,
              ),
            ),
            child: Icon(
              riskIcon,
              size: 46,
              color: riskColor,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_risk!.riskLevel.toUpperCase()} RISK',
              style: TextStyle(
                color: riskColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _risk!.locationName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Risk Score',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_risk!.riskScore.toStringAsFixed(0)}/100',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (_risk!.riskScore / 100)
                  .clamp(0.0, 1.0),
              minHeight: 11,
              backgroundColor: Colors.grey.shade200,
              color: riskColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveConditionsCard() {
    return _SectionCard(
      title: 'Live Conditions',
      icon: Icons.public,
      iconColor: Colors.blue,
      child: Column(
        children: [
          _ConditionTile(
            icon: Icons.thermostat_outlined,
            iconColor: Colors.orange,
            label: 'Temperature',
            value: _temperature == null
                ? 'Unavailable'
                : '${_temperature!.toStringAsFixed(1)} °C',
          ),
          const SizedBox(height: 10),
          _ConditionTile(
            icon: Icons.cloud_outlined,
            iconColor: Colors.blue,
            label: 'Weather',
            value: _weatherDescription.isEmpty
                ? 'Unavailable'
                : _weatherDescription,
          ),
          const SizedBox(height: 10),
          _ConditionTile(
            icon: Icons.warning_amber_rounded,
            iconColor:
                _hasActiveAlert
                    ? Colors.red
                    : Colors.green,
            label: 'Safety Alerts',
            value: _hasActiveAlert
                ? 'Active alert available'
                : 'No active alert',
            valueColor:
                _hasActiveAlert
                    ? Colors.red.shade700
                    : Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildReasonsCard() {
    return _SectionCard(
      title: 'Why this risk level?',
      icon: Icons.analytics_outlined,
      iconColor: Colors.deepPurple,
      child: Column(
        children: _risk!.reasons
            .map(
              (reason) => _BulletItem(
                icon: Icons.check_circle_outline,
                iconColor: Colors.blue,
                text: reason,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return _SectionCard(
      title: 'Safety Recommendations',
      icon: Icons.shield_outlined,
      iconColor: Colors.green,
      child: Column(
        children: _risk!.recommendations
            .map(
              (recommendation) => _BulletItem(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                text: recommendation,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'Risk analysis is an assistive safety feature. '
              'Always follow official local warnings and '
              'emergency instructions.',
              style: TextStyle(
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(25),
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Analyzing current safety conditions...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Checking your location, weather and active alerts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Risk Analysis Unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _analyzeRealRisk,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 40,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No risk information available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Refresh the analysis to check the latest safety conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _ConditionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 19,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade700,
                fontSize: 13,
                fontWeight:
                    valueColor != null
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _BulletItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.4,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}