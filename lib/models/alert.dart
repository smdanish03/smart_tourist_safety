class SafetyAlert {
  final String alertId;
  final String title;
  final String message;
  final String severity;
  final String locationName;
  final DateTime createdAt;
  final bool active;

  const SafetyAlert({
    required this.alertId,
    required this.title,
    required this.message,
    required this.severity,
    required this.locationName,
    required this.createdAt,
    required this.active,
  });

  factory SafetyAlert.fromMap(
    Map<String, dynamic> map,
  ) {
    return SafetyAlert(
      alertId: map['alertId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      severity: map['severity']?.toString() ?? 'Info',
      locationName:
          map['locationName']?.toString() ?? 'Mumbai',
      createdAt: DateTime.tryParse(
            map['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      active: map['active'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'title': title,
      'message': message,
      'severity': severity,
      'locationName': locationName,
      'createdAt': createdAt.toIso8601String(),
      'active': active,
    };
  }
}