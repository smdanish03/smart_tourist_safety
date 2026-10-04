
class TouristRisk {
  final String riskLevel;
  final double riskScore;
  final String locationName;
  final List<String> reasons;
  final List<String> recommendations;
  final DateTime generatedAt;

  const TouristRisk({
    required this.riskLevel,
    required this.riskScore,
    required this.locationName,
    required this.reasons,
    required this.recommendations,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'riskLevel': riskLevel,
      'riskScore': riskScore,
      'locationName': locationName,
      'reasons': reasons,
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory TouristRisk.fromMap(
    Map<String, dynamic> map,
  ) {
    return TouristRisk(
      riskLevel:
          map['riskLevel']?.toString() ?? 'Low',
      riskScore:
          (map['riskScore'] as num?)?.toDouble() ?? 0,
      locationName:
          map['locationName']?.toString() ?? 'Unknown',
      reasons:
          List<String>.from(
        map['reasons'] ?? [],
      ),
      recommendations:
          List<String>.from(
        map['recommendations'] ?? [],
      ),
      generatedAt: DateTime.tryParse(
            map['generatedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
