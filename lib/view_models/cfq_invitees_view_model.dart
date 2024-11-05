import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as model;
import '../models/cfq_event_model.dart';
import '../providers/auth_methods.dart';
import '../utils/logger.dart';

class CFQInviteesViewModel extends ChangeNotifier {
  final String cfqId;
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Cfq? _cfq;
  String? _currentUserId;
  List<model.User> _followingUp = [];
  List<model.User> _invitees = [];

  Cfq? get cfq => _cfq;
  String? get currentUserId => _currentUserId;
  List<model.User> get followingUp => _followingUp;
  List<model.User> get invitees => _invitees;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  CFQInviteesViewModel({required this.cfqId}) {
    _init();
  }

  Future<void> _init() async {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    await _fetchCFQDetails();
    await _fetchInvitees();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchCFQDetails() async {
    try {
      DocumentSnapshot cfqDoc =
          await _firestore.collection('cfqs').doc(cfqId).get();
      _cfq = Cfq.fromJson(cfqDoc.data() as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Error fetching CFQ details: $e');
    }
  }

  Future<void> _fetchInvitees() async {
    if (_cfq == null) return;
    try {
      _followingUp = await _fetchUsers(
          _cfq!.followingUp.where((id) => id != _currentUserId).toList());
      _invitees = await _fetchUsers(
          _cfq!.invitees.where((id) => id != _currentUserId).toList());

      // Add current user to the appropriate list if they're included
      if (_currentUserId != null) {
        model.User currentUser =
            await _authMethods.getUserDetailsById(_currentUserId!);
        if (_cfq!.followingUp.contains(_currentUserId)) {
          _followingUp.insert(0, currentUser);
        }
        if (_cfq!.invitees.contains(_currentUserId)) {
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
}
