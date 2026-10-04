class Incident {
  final String reportId;
  final String touristId;
  final String uid;

  final String touristName;
  final String email;
  final String phone;
  final String city;

  final String incidentType;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime createdAt;
  final String status;

  const Incident({
    required this.reportId,
    required this.touristId,
    required this.uid,
    required this.touristName,
    required this.email,
    required this.phone,
    required this.city,
    required this.incidentType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'touristId': touristId,
      'uid': uid,
      'touristName': touristName,
      'email': email,
      'phone': phone,
      'city': city,
      'incidentType': incidentType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Incident.fromMap(
    Map<String, dynamic> map,
  ) {
    return Incident(
      reportId:
          map['reportId']?.toString() ?? '',
      touristId:
          map['touristId']?.toString() ?? '',
      uid:
          map['uid']?.toString() ?? '',

      touristName:
          map['touristName']?.toString() ?? '',
      email:
          map['email']?.toString() ?? '',
      phone:
          map['phone']?.toString() ?? '',
      city:
          map['city']?.toString() ?? '',

      incidentType:
          map['incidentType']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      latitude:
          (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude:
          (map['longitude'] as num?)?.toDouble() ?? 0,
      locationName:
          map['locationName']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(
                map['createdAt']?.toString() ?? '',
              ) ??
              DateTime.now(),
      status:
          map['status']?.toString() ?? 'Submitted',
    );
  }
}