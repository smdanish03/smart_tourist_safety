class Hospital {
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;
  final bool? emergency;

  const Hospital({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
    this.emergency,
  });
}