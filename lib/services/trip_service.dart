import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip.dart';

class TripService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tripsCollection {
    return _firestore.collection('trips');
  }

  User? get _currentUser => _auth.currentUser;

  Future<String> saveTrip(Trip trip) async {
    final User? user = _currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final DocumentReference<Map<String, dynamic>> doc =
        _tripsCollection.doc();

    final Trip tripToSave = Trip(
      id: doc.id,
      uid: user.uid,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      days: trip.days,
      createdAt: trip.createdAt ?? DateTime.now(),
    );

    await doc.set(tripToSave.toMap());

    return doc.id;
  }

  Future<List<Trip>> getMyTrips() async {
    final User? user = _currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _tripsCollection
            .where('uid', isEqualTo: user.uid)
            .get();

    final List<Trip> trips = snapshot.docs.map((doc) {
      return Trip.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    trips.sort((a, b) {
      final DateTime aDate =
          a.createdAt ?? DateTime(2000);

      final DateTime bDate =
          b.createdAt ?? DateTime(2000);

      return bDate.compareTo(aDate);
    });

    return trips;
  }

  Future<Trip?> getTrip(String tripId) async {
    final User? user = _currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _tripsCollection.doc(tripId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final Map<String, dynamic> data = doc.data()!;

    if (data['uid'] != user.uid) {
      throw Exception('You are not allowed to access this trip.');
    }

    return Trip.fromMap(
      doc.id,
      data,
    );
  }

  Future<void> deleteTrip(String tripId) async {
    final User? user = _currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _tripsCollection.doc(tripId).get();

    if (!doc.exists || doc.data() == null) {
      return;
    }

    final Map<String, dynamic> data = doc.data()!;

    if (data['uid'] != user.uid) {
      throw Exception('You are not allowed to delete this trip.');
    }

    await _tripsCollection.doc(tripId).delete();
  }
}