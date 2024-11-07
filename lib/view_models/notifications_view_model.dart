import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart' as model;
import '../utils/logger.dart';
import 'dart:async';

class NotificationsViewModel extends ChangeNotifier {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<model.Notification> _notifications = [];
  bool _isLoading = true;
  StreamSubscription? _unreadCountSubscription;
  int _unreadNotificationsCount = 0;

  int get unreadNotificationsCount => _unreadNotificationsCount;

  List<model.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  Stream<int> get unreadCountStream => _firestore
      .collection('users')
      .doc(currentUserUid)
      .snapshots()
      .map((snapshot) => snapshot.get('unreadNotificationsCount') ?? 0);

  NotificationsViewModel({required this.currentUserUid}) {
    _loadNotifications();
    _setupUnreadCountStream();
  }

  Future<void> _loadNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userDoc =
          await _firestore.collection('users').doc(currentUserUid).get();
      final String notificationChannelId =
          userDoc.get('notificationsChannelId');

      final querySnapshot = await _firestore
          .collection('notifications')
          .doc(notificationChannelId)
          .collection('userNotifications')
          .orderBy('timestamp', descending: true)
          .get();

      AppLogger.debug('Found ${querySnapshot.docs.length} notifications');
      AppLogger.debug(
          'Notification types: ${querySnapshot.docs.map((doc) => (doc.data()['type'] as String)).toList()}');

      _notifications = querySnapshot.docs
          .map((doc) => model.Notification.fromSnap(doc))
          .where((notification) =>
              notification.type == model.NotificationType.eventInvitation ||
              notification.type == model.NotificationType.followUp ||
              notification.type == model.NotificationType.attending ||
              notification.type == model.NotificationType.teamRequest ||
              notification.type == model.NotificationType.friendRequest)
          .toList();

      AppLogger.debug('Filtered to ${_notifications.length} notifications');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading notifications: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupUnreadCountStream() {
    _unreadCountSubscription = _firestore
        .collection('users')
        .doc(currentUserUid)
        .snapshots()
        .listen((snapshot) {
      _unreadNotificationsCount = snapshot.get('unreadNotificationsCount') ?? 0;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> resetUnreadCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({'unreadNotificationsCount': 0});
    } catch (e) {
      AppLogger.error('Error resetting unread notifications count: $e');
    }
  }
}
