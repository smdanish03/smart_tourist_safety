class Trip {
  final String id;
  final String uid;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripDay> days;
  final DateTime? createdAt;

  const Trip({
    required this.id,
    required this.uid,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((day) => day.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory Trip.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Trip(
      id: id,
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      startDate: _toDateTime(map['startDate']),
      endDate: _toDateTime(map['endDate']),
      days: (map['days'] as List<dynamic>? ?? [])
          .map(
            (day) => TripDay.fromMap(
              Map<String, dynamic>.from(day as Map),
            ),
          )
          .toList(),
      createdAt: map['createdAt'] != null
          ? _toDateTime(map['createdAt'])
          : null,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value != null && value.runtimeType.toString() == 'Timestamp') {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}

class TripDay {
  final int dayNumber;
  final DateTime date;
  final List<TripPlace> places;

  const TripDay({
    required this.dayNumber,
    required this.date,
    required this.places,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'date': date,
      'places': places.map((place) => place.toMap()).toList(),
    };
  }

  factory TripDay.fromMap(Map<String, dynamic> map) {
    return TripDay(
      dayNumber: map['dayNumber'] ?? 1,
      date: Trip._toDateTime(map['date']),
      places: (map['places'] as List<dynamic>? ?? [])
          .map(
            (place) => TripPlace.fromMap(
              Map<String, dynamic>.from(place as Map),
            ),
          )
          .toList(),
    );
  }
}

class TripPlace {
  final String placeId;
  final String name;
  final String category;
  final double latitude;
  final double longitude;

  const TripPlace({
    required this.placeId,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory TripPlace.fromMap(Map<String, dynamic> map) {
    return TripPlace(
      placeId: map['placeId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }
}