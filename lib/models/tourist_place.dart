class TouristPlace {
  final String name;
  final String category;
  final String about;
  final String history;
  final double latitude;
  final double longitude;
  final List<String> thingsToDo;
  final List<String> safetyTips;
  final List<String> nearbyFood;
  final String visitingInfo;
  final String planTips;

  const TouristPlace({
    required this.name,
    required this.category,
    required this.about,
    required this.history,
    required this.latitude,
    required this.longitude,
    required this.thingsToDo,
    required this.safetyTips,
    required this.nearbyFood,
    required this.visitingInfo,
    required this.planTips,
  });
}