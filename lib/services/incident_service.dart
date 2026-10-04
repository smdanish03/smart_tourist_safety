import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> submitIncident(
    Incident incident,
  ) async {
    await _firestore
        .collection('incidents')
        .doc(incident.reportId)
        .set(
          incident.toMap(),
        );
  }

  Future<List<Incident>> getMyIncidents(
    String touristId,
  ) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('incidents')
            .where(
              'touristId',
              isEqualTo: touristId,
            )
            .get();

    final List<Incident> incidents =
        snapshot.docs.map(
      (doc) {
        return Incident.fromMap(
          doc.data(),
        );
      },
    ).toList();

    incidents.sort(
      (a, b) =>
          b.createdAt.compareTo(a.createdAt),
    );

    return incidents;
  }
}