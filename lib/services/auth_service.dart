import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final Random _random = Random.secure();

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<String> createAccount({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String password,
  }) async {
    final String cleanName = name.trim();
    final String cleanEmail =
        email.trim().toLowerCase();
    final String cleanPhone = phone.trim();
    final String cleanCity = city.trim();
    final String cleanPassword =
        password.trim();

    if (cleanName.isEmpty) {
      throw Exception(
        'Please enter your name.',
      );
    }

    if (!_isValidEmail(cleanEmail)) {
      throw Exception(
        'Please enter a valid email address.',
      );
    }

    if (cleanPhone.isEmpty) {
      throw Exception(
        'Please enter your phone number.',
      );
    }

    if (cleanCity.isEmpty) {
      throw Exception(
        'Please enter your city.',
      );
    }

    if (!_isValidAlphanumeric(
      cleanPassword,
      6,
    )) {
      throw Exception(
        'Password must contain exactly 6 letters or numbers.',
      );
    }

    final String emailKey =
        Uri.encodeComponent(cleanEmail);

    // ----------------------------------------------------------
    // Generate unique Tourist ID
    // ----------------------------------------------------------

    for (int attempt = 0; attempt < 10; attempt++) {
      final String touristId =
          _generateTouristId();

      final String internalEmail =
          '${touristId.toLowerCase()}@smarttouristsafety.app';

      User? user;

      try {
        // ======================================================
        // 1. CREATE FIREBASE AUTH USER
        // ======================================================

        final UserCredential credential =
            await _auth
                .createUserWithEmailAndPassword(
          email: internalEmail,
          password: cleanPassword,
        );

        user = credential.user;

        if (user == null) {
          throw Exception(
            'Unable to create the account.',
          );
        }

        // ======================================================
        // 2. RESERVE REAL EMAIL
        // ======================================================

        try {
          await _firestore
              .collection('emailIndex')
              .doc(emailKey)
              .set({
            'uid': user.uid,
            'emailKey': emailKey,
            'email': cleanEmail,
            'touristId': touristId,
            'createdAt':
                FieldValue.serverTimestamp(),
          });
        } catch (e) {
          await user.delete();

          if (e is FirebaseException &&
              (e.code == 'permission-denied' ||
                  e.code == 'already-exists')) {
            throw Exception(
              'An account already exists with this email address.',
            );
          }

          rethrow;
        }

        // ======================================================
        // 3. CREATE TOURIST PROFILE
        // ======================================================

        try {
          await _firestore
              .collection('tourists')
              .doc(touristId)
              .set({
            'uid': user.uid,
            'touristId': touristId,
            'name': cleanName,
            'fullName': cleanName,
            'email': cleanEmail,
            'phone': cleanPhone,
            'city': cleanCity,
            'createdAt':
                FieldValue.serverTimestamp(),
          });
        } catch (e) {
          try {
            await _firestore
                .collection('emailIndex')
                .doc(emailKey)
                .delete();
          } catch (_) {}

          await user.delete();

          rethrow;
        }

        return touristId;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Generated Tourist ID already exists.
          // Try another ID.
          continue;
        }

        throw Exception(
          _getAuthErrorMessage(e.code),
        );
      }
    }

    throw Exception(
      'Unable to generate a unique Tourist ID. Please try again.',
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserCredential> login({
    required String touristId,
    required String password,
  }) async {
    final String cleanTouristId =
        touristId.trim().toUpperCase();

    final String cleanPassword =
        password.trim();

    if (!_isValidAlphanumeric(
      cleanTouristId,
      5,
    )) {
      throw Exception(
        'Tourist ID must contain exactly 5 letters or numbers.',
      );
    }

    if (!_isValidAlphanumeric(
      cleanPassword,
      6,
    )) {
      throw Exception(
        'Password must contain exactly 6 letters or numbers.',
      );
    }

    final String internalEmail =
        '${cleanTouristId.toLowerCase()}@smarttouristsafety.app';

    try {
      return await _auth
          .signInWithEmailAndPassword(
        email: internalEmail,
        password: cleanPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  // ============================================================
  // FIND TOURIST ID BY REAL EMAIL
  // ============================================================

  Future<String?> findTouristIdByEmail(
    String email,
  ) async {
    final String cleanEmail =
        email.trim().toLowerCase();

    if (!_isValidEmail(cleanEmail)) {
      throw Exception(
        'Please enter a valid email address.',
      );
    }

    final String emailKey =
        Uri.encodeComponent(cleanEmail);

    try {
      final DocumentSnapshot<
              Map<String, dynamic>>
          document =
          await _firestore
              .collection('emailIndex')
              .doc(emailKey)
              .get();

      if (!document.exists) {
        return null;
      }

      final Map<String, dynamic> data =
          document.data() ?? {};

      final String touristId =
          (data['touristId'] ?? '')
              .toString();

      if (touristId.isEmpty) {
        return null;
      }

      return touristId;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Email recovery is not enabled in Firestore rules yet.',
        );
      }

      rethrow;
    }
  }

  // ============================================================
  // FIND REGISTERED EMAIL BY TOURIST ID
  // ============================================================

  Future<String?> findEmailByTouristId(
    String touristId,
  ) async {
    final String cleanTouristId =
        touristId.trim().toUpperCase();

    if (!_isValidAlphanumeric(
      cleanTouristId,
      5,
    )) {
      throw Exception(
        'Tourist ID must contain exactly 5 letters or numbers.',
      );
    }

    final DocumentSnapshot<
            Map<String, dynamic>>
        document =
        await _firestore
            .collection('tourists')
            .doc(cleanTouristId)
            .get();

    if (!document.exists) {
      return null;
    }

    final Map<String, dynamic> data =
        document.data() ?? {};

    final String email =
        (data['email'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

    if (email.isEmpty) {
      return null;
    }

    return email;
  }

  // ============================================================
  // SEND PASSWORD RESET
  // ============================================================
  //
  // NOTE:
  // Your Firebase Auth account currently uses:
  //
  // TOURISTID@smarttouristsafety.app
  //
  // Therefore Firebase's normal reset email cannot be sent
  // directly to the tourist's real email.
  //
  // This method is kept here so the recovery architecture is
  // ready. A real-email password reset requires changing the
  // Firebase authentication architecture or adding a backend/
  // Cloud Function.
  //
  // ============================================================

  Future<void> requestPasswordReset({
    required String touristId,
  }) async {
    final String cleanTouristId =
        touristId.trim().toUpperCase();

    if (!_isValidAlphanumeric(
      cleanTouristId,
      5,
    )) {
      throw Exception(
        'Tourist ID must contain exactly 5 letters or numbers.',
      );
    }

    final String? realEmail =
        await findEmailByTouristId(
      cleanTouristId,
    );

    if (realEmail == null ||
        realEmail.isEmpty) {
      throw Exception(
        'No account was found with this Tourist ID.',
      );
    }

    throw Exception(
      'Password recovery requires the secure email-reset backend to be enabled.',
    );
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser =>
      _auth.currentUser;

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // TOURIST ID GENERATOR
  // ============================================================

  String _generateTouristId() {
    final StringBuffer id =
        StringBuffer();

    for (int i = 0; i < 5; i++) {
      final int index =
          _random.nextInt(
        _characters.length,
      );

      id.write(
        _characters[index],
      );
    }

    return id.toString();
  }

  // ============================================================
  // ALPHANUMERIC VALIDATION
  // ============================================================

  bool _isValidAlphanumeric(
    String value,
    int length,
  ) {
    if (value.length != length) {
      return false;
    }

    final RegExp regex =
        RegExp(r'^[A-Za-z0-9]+$');

    return regex.hasMatch(value);
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    return regex.hasMatch(email);
  }

  // ============================================================
  // FIREBASE ERROR MESSAGES
  // ============================================================

  String _getAuthErrorMessage(
    String code,
  ) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid Tourist ID or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'email-already-in-use':
        return 'This Tourist ID is already in use.';

      case 'weak-password':
        return 'Password must contain exactly 6 letters or numbers.';

      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled in Firebase.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}