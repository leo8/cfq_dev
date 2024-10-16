import 'package:flutter/material.dart';
import '../models/user.dart' as model;
import '../models/team.dart';

abstract class InviteesSelectorViewModel extends ChangeNotifier {
  List<model.User> get selectedInvitees;
  List<Team> get selectedTeamInvitees;
  List<dynamic> get searchResults;
  bool get isSearching;
  bool get isEverybodySelected;
  TextEditingController get searchController;

  void toggleInvitee(model.User invitee);
  void toggleTeam(Team team);
  void toggleEverybody();
  Future<void> performSearch(String query);
  void addInvitee(model.User invitee);
  void addTeam(Team team);
  void removeInvitee(model.User invitee);
  void removeTeam(Team team);
  void selectEverybody();
}
