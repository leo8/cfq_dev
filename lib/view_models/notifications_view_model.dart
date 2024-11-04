import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart' as model;
import '../utils/logger.dart';

class NotificationsViewModel extends ChangeNotifier {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<model.Notification> _notifications = [];
  bool _isLoading = false;

  List<model.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  NotificationsViewModel({required this.currentUserUid}) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get user's notifications channel ID
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserUid).get();
      String notificationsChannelId = userDoc.get('notificationsChannelId');

      // Listen to notifications
      _firestore
          .collection('notifications')
          .doc(notificationsChannelId)
          .collection('userNotifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        _notifications = snapshot.docs
            .map((doc) => model.Notification.fromSnap(doc))
            .where((notification) =>
                notification.type == model.NotificationType.eventInvitation)
            .toList();

        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      AppLogger.error('Error loading notifications: $e');
      notifyListeners();
    }
  }
}
