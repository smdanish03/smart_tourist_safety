class PoliceStation {
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;

  const PoliceStation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
  });
}