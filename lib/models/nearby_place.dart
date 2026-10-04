class NearbyPlace {
  final String name;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final double? distanceMeters;

  const NearbyPlace({
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.distanceMeters,
  });
}