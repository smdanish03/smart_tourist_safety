import 'package:flutter/material.dart';

import '../smart/geofence_page.dart';
import 'alerts_page.dart';
import 'incident_report_page.dart';
import 'nearby_hospitals_page.dart';
import 'nearby_police_page.dart';
import 'risk_analysis_page.dart';

class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Safety',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          // --------------------------------------------------
          // Header
          // --------------------------------------------------
          const Text(
            'Stay Safe While Travelling',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Access safety services, alerts and useful travel safety information.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // Safety Overview
          // --------------------------------------------------
          const _SafetyOverviewCard(),

          const SizedBox(height: 18),

          const Text(
            'Safety Services',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 10),

          // --------------------------------------------------
          // Nearby Police
          // --------------------------------------------------
          _SafetyFeatureCard(
            icon: Icons.local_police,
            iconColor: Colors.blue,
            title: 'Nearby Police',
            subtitle:
                'Find police stations near your current location.',
            buttonText: 'Find Police',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NearbyPolicePage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // Nearby Hospitals
          // --------------------------------------------------
          _SafetyFeatureCard(
            icon: Icons.local_hospital,
            iconColor: Colors.red,
            title: 'Nearby Hospitals',
            subtitle:
                'Find nearby hospitals and emergency medical help.',
            buttonText: 'Find Hospitals',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NearbyHospitalsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // Incident Report
          // --------------------------------------------------
          _SafetyFeatureCard(
            icon: Icons.report_problem,
            iconColor: Colors.orange,
            title: 'Report an Incident',
            subtitle:
                'Report a safety incident with location and details.',
            buttonText: 'Report Incident',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IncidentReportPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // Safety Alerts
          // --------------------------------------------------
          _SafetyFeatureCard(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.amber.shade800,
            title: 'Safety Alerts',
            subtitle:
                'View important safety and emergency alerts.',
            buttonText: 'View Alerts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlertsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // Geo-Fencing
          // --------------------------------------------------
          _SafetyFeatureCard(
            icon: Icons.location_searching,
            iconColor: Colors.deepPurple,
            title: 'Geo-Fencing',
            subtitle:
                'Check whether you are inside a defined tourist safety zone.',
            buttonText: 'Check Zone',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GeofencePage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // AI Risk Analysis
          // --------------------------------------------------
          _SafetyFeatureCard(
            icon: Icons.psychology,
            iconColor: Colors.teal,
            title: 'AI Risk Analysis',
            subtitle:
                'Analyze your current travel conditions and get a safety risk level.',
            buttonText: 'Check Risk',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RiskAnalysisPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Safety Overview Card
// --------------------------------------------------

class _SafetyOverviewCard extends StatelessWidget {
  const _SafetyOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Information & Tips',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simple steps for a safer journey.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _SafetyTip(
            icon: Icons.location_on_rounded,
            title: 'Stay Aware of Your Location',
            description:
                'Keep track of your current location and know your nearby landmarks.',
          ),

          const _SafetyTip(
            icon: Icons.groups_rounded,
            title: 'Stay in Crowded Areas',
            description:
                'Prefer well-known and populated places, especially when travelling alone.',
          ),

          const _SafetyTip(
            icon: Icons.phone_android_rounded,
            title: 'Keep Your Phone Charged',
            description:
                'Keep your phone and important communication services available during travel.',
          ),

          const _SafetyTip(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Protect Your Belongings',
            description:
                'Keep your phone, wallet, documents and other valuables secure.',
          ),

          const _SafetyTip(
            icon: Icons.cloud_rounded,
            title: 'Check Weather and Alerts',
            description:
                'Check current weather conditions and safety alerts before travelling.',
          ),

          const _SafetyTip(
            icon: Icons.people_alt_rounded,
            title: 'Share Your Trip Information',
            description:
                'Inform a trusted person about your travel plans when travelling alone.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Individual Safety Tip
// --------------------------------------------------

class _SafetyTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;

  const _SafetyTip({
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 19,
              color: Colors.green,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
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

// --------------------------------------------------
// Safety Feature Card
// --------------------------------------------------

class _SafetyFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const _SafetyFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 11),

                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                    ),
                    label: Text(buttonText),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(
                        color: iconColor.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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