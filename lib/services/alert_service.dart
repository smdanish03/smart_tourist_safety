import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/alert.dart';
import 'notification_service.dart';

class AlertService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Alerts for which a notification has already
  // been attempted during the current app session.
  static final Set<String> _notifiedAlertIds =
      <String>{};

  // ------------------------------------------------------------
  // GET ACTIVE ALERTS
  // ------------------------------------------------------------

  Future<List<SafetyAlert>> getActiveAlerts() async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot = await _firestore
            .collection('alerts')
            .where(
              'active',
              isEqualTo: true,
            )
            .get();

    final List<SafetyAlert> alerts = [];

    for (final QueryDocumentSnapshot<
        Map<String, dynamic>> document
        in snapshot.docs) {
      try {
        final SafetyAlert alert =
            SafetyAlert.fromMap(
          document.data(),
        );

        alerts.add(alert);
      } catch (_) {
        // Ignore an invalid alert document so that
        // one bad document does not break the
        // complete Safety Alerts screen.
        continue;
      }
    }

    // Newest alerts first.
    alerts.sort(
      (a, b) =>
          b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    // Notification failure must NEVER prevent
    // alerts from being displayed.
    _sendNewAlertNotifications(
      alerts,
    );

    return alerts;
  }

  // ------------------------------------------------------------
  // SEND NOTIFICATIONS
  // ------------------------------------------------------------

  void _sendNewAlertNotifications(
    List<SafetyAlert> alerts,
  ) {
    // flutter_local_notifications is intended for
    // Android/iOS. Do not run it while testing the
    // Flutter web app in Chrome.
    if (kIsWeb) {
      return;
    }

    for (final SafetyAlert alert in alerts) {
      if (_notifiedAlertIds.contains(
        alert.alertId,
      )) {
        continue;
      }

      _notifiedAlertIds.add(
        alert.alertId,
      );

      _showNotificationSafely(
        alert,
      );
    }
  }

  // ------------------------------------------------------------
  // SAFE NOTIFICATION
  // ------------------------------------------------------------

  Future<void> _showNotificationSafely(
    SafetyAlert alert,
  ) async {
    try {
      await NotificationService.showSafetyAlert(
        title: alert.title,
        message:
            '${alert.message} Location: ${alert.locationName}',
      );
    } catch (_) {
      // Notification failure should never affect
      // the Safety Alerts screen.
    }
  }

  // ------------------------------------------------------------
  // GET ALL ALERTS
  // ------------------------------------------------------------
  //
  // Useful later for Admin or history screens.
  //

  Future<List<SafetyAlert>> getAllAlerts() async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot = await _firestore
            .collection('alerts')
            .get();

    final List<SafetyAlert> alerts = [];

    for (final QueryDocumentSnapshot<
        Map<String, dynamic>> document
        in snapshot.docs) {
      try {
        alerts.add(
          SafetyAlert.fromMap(
            document.data(),
          ),
        );
      } catch (_) {
        continue;
      }
    }

    alerts.sort(
      (a, b) =>
          b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    return alerts;
  }
}