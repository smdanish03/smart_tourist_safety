import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<bool> isCurrentUserAdmin() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final DocumentSnapshot<Map<String, dynamic>> document =
        await _firestore
            .collection('admins')
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return false;
    }

    final Map<String, dynamic>? data =
        document.data();

    if (data == null) {
      return false;
    }

    final String role =
        data['role']?.toString() ?? '';

    final bool active =
        data['active'] == true;

    return role == 'admin' && active;
  }

  Future<Map<String, dynamic>?> getCurrentAdmin() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> document =
        await _firestore
            .collection('admins')
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}