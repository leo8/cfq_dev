import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as model;
import '../models/turn_event_model.dart';
import '../providers/auth_methods.dart';
import '../utils/logger.dart';

class TurnInviteesViewModel extends ChangeNotifier {
  final String turnId;
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Turn? _turn;
  String? _currentUserId;
  List<model.User> _attending = [];
  List<model.User> _notSureAttending = [];
  List<model.User> _notAttending = [];
  List<model.User> _invitees = [];

  Turn? get turn => _turn;
  String? get currentUserId => _currentUserId;
  List<model.User> get attending => _attending;
  List<model.User> get notSureAttending => _notSureAttending;
  List<model.User> get notAttending => _notAttending;
  List<model.User> get invitees => _invitees;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  TurnInviteesViewModel({required this.turnId}) {
    _init();
  }

  Future<void> _init() async {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    await _fetchTurnData();
    await _fetchInvitees();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchTurnData() async {
    try {
      DocumentSnapshot turnDoc =
          await _firestore.collection('turns').doc(turnId).get();
      Map<String, dynamic> turnData = turnDoc.data() as Map<String, dynamic>;
      _turn = Turn.fromJson(turnData);
    } catch (e) {
      AppLogger.error('Error fetching turn data: $e');
    }
  }

  Future<void> _fetchInvitees() async {
    if (_turn == null) return;

    try {
      _attending = await _fetchUsers(
          _turn!.attending.where((id) => id != _currentUserId).toList());
      _notSureAttending = await _fetchUsers(
          _turn!.notSureAttending.where((id) => id != _currentUserId).toList());
      _notAttending = await _fetchUsers(
          _turn!.notAttending.where((id) => id != _currentUserId).toList());
      _invitees = await _fetchUsers(
          _turn!.invitees.where((id) => id != _currentUserId).toList());

      // Add current user to the appropriate list if they're included
      if (_currentUserId != null) {
        model.User currentUser =
            await _authMethods.getUserDetailsById(_currentUserId!);
        if (_turn!.attending.contains(_currentUserId)) {
          _attending.insert(0, currentUser);
        }
        if (_turn!.notSureAttending.contains(_currentUserId)) {
          _notSureAttending.insert(0, currentUser);
        }
        if (_turn!.notAttending.contains(_currentUserId)) {
          _notAttending.insert(0, currentUser);
        }
        if (_turn!.invitees.contains(_currentUserId)) {
          _invitees.insert(0, currentUser);
        }
      }
    } catch (e) {
      AppLogger.error('Error fetching invitees: $e');
    }
  }

  Future<List<model.User>> _fetchUsers(List<String> userIds) async {
    List<model.User> users = [];
    for (String uid in userIds) {
      try {
        model.User user = await _authMethods.getUserDetailsById(uid);
        users.add(user);
      } catch (e) {
        AppLogger.error('Error fetching user $uid: $e');
      }
    }
    return users;
  }

  void _removeUserFromLists(String? userId) {
    if (userId == null) return;
    _attending.removeWhere((user) => user.uid == userId);
    _notSureAttending.removeWhere((user) => user.uid == userId);
    _notAttending.removeWhere((user) => user.uid == userId);
    _invitees.removeWhere((user) => user.uid == userId);
  }
}
