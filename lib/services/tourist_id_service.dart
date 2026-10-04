
import 'package:cloud_firestore/cloud_firestore.dart';

class TouristIdService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getTouristData(
    String touristId,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _firestore
            .collection('tourists')
            .doc(touristId)
            .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}
