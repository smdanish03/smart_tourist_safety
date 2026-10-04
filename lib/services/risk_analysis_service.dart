
import '../models/tourist_risk.dart';

class RiskAnalysisService {
  TouristRisk analyzeRisk({
    required String locationName,
    required double temperature,
    required bool activeSafetyAlert,
    required bool nearEmergencyArea,
  }) {
    double score = 0;

    final List<String> reasons = [];
    final List<String> recommendations = [];

    // Weather condition
    if (temperature >= 38) {
      score += 25;
      reasons.add(
        'High temperature may cause heat-related discomfort.',
      );
      recommendations.add(
        'Carry sufficient drinking water and avoid prolonged exposure to heat.',
      );
    } else if (temperature >= 35) {
      score += 15;
      reasons.add(
        'Temperature is relatively high.',
      );
      recommendations.add(
        'Stay hydrated and take breaks during outdoor activities.',
      );
    }

    // Active safety alert
    if (activeSafetyAlert) {
      score += 35;
      reasons.add(
        'An active safety alert is currently available.',
      );
      recommendations.add(
        'Check the latest safety alert and follow local instructions.',
      );
    }

    // Emergency area proximity
    if (nearEmergencyArea) {
      score += 20;
      reasons.add(
        'The tourist is currently near an emergency-related area.',
      );
      recommendations.add(
        'Stay aware of your surroundings and keep emergency contacts accessible.',
      );
    }

    // Determine risk level
    String riskLevel;

    if (score >= 60) {
      riskLevel = 'High';
      recommendations.add(
        'Consider avoiding unnecessary travel until conditions improve.',
      );
    } else if (score >= 30) {
      riskLevel = 'Medium';
      recommendations.add(
        'Travel carefully and remain alert to local conditions.',
      );
    } else {
      riskLevel = 'Low';
      recommendations.add(
        'Continue following normal tourist safety precautions.',
      );
    }

    // Keep score within 0-100.
    if (score > 100) {
      score = 100;
    }

    if (reasons.isEmpty) {
      reasons.add(
        'No major risk factors were detected.',
      );
    }

    return TouristRisk(
      riskLevel: riskLevel,
      riskScore: score,
      locationName: locationName,
      reasons: reasons,
      recommendations: recommendations,
      generatedAt: DateTime.now(),
    );
  }
}
