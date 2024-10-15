import 'package:flutter/material.dart';
import '../widgets/molecules/invitees_field.dart';
import '../models/user.dart' as model;
import '../models/team.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';
import '../utils/logger.dart';

class InviteesSelectorScreen extends StatefulWidget {
  final List<model.User> initialSelectedInvitees;
  final List<Team> initialSelectedTeams;
  final List<dynamic> searchResults;
  final TextEditingController searchController;
  final bool isSearching;
  final Function(model.User) onAddInvitee;
  final Function(model.User) onRemoveInvitee;
  final Function(Team) onAddTeam;
  final Function(Team) onRemoveTeam;
  final Function(String) onSearch;
  final VoidCallback onSelectEverybody;
  final bool isEverybodySelected;

  const InviteesSelectorScreen({
    Key? key,
    required this.initialSelectedInvitees,
    required this.initialSelectedTeams,
    required this.searchResults,
    required this.searchController,
    required this.isSearching,
    required this.onAddInvitee,
    required this.onRemoveInvitee,
    required this.onAddTeam,
    required this.onRemoveTeam,
    required this.onSearch,
    required this.onSelectEverybody,
    required this.isEverybodySelected,
  }) : super(key: key);

  @override
  _InviteesSelectorScreenState createState() => _InviteesSelectorScreenState();
}

class _InviteesSelectorScreenState extends State<InviteesSelectorScreen> {
  late List<model.User> _selectedInvitees;
  late List<Team> _selectedTeams;

  @override
  void initState() {
    super.initState();
    _selectedInvitees = List.from(widget.initialSelectedInvitees);
    _selectedTeams = List.from(widget.initialSelectedTeams);
    AppLogger.debug('InviteesSelectorScreen initialized');
    AppLogger.debug('Initial selected invitees: ${_selectedInvitees.length}');
    AppLogger.debug('Initial selected teams: ${_selectedTeams.length}');
  }

  void _onAddInvitee(model.User invitee) {
    setState(() {
      _selectedInvitees.add(invitee);
    });
    widget.onAddInvitee(invitee);
    AppLogger.debug('Invitee added: ${invitee.username}');
    AppLogger.debug('Total selected invitees: ${_selectedInvitees.length}');
  }

  void _onRemoveInvitee(model.User invitee) {
    setState(() {
      _selectedInvitees.remove(invitee);
    });
    widget.onRemoveInvitee(invitee);
    AppLogger.debug('Invitee removed: ${invitee.username}');
    AppLogger.debug('Total selected invitees: ${_selectedInvitees.length}');
  }

  void _onAddTeam(Team team) {
    setState(() {
      _selectedTeams.add(team);
    });
    widget.onAddTeam(team);
    AppLogger.debug('Team added: ${team.name}');
    AppLogger.debug('Total selected teams: ${_selectedTeams.length}');
  }

  void _onRemoveTeam(Team team) {
    setState(() {
      _selectedTeams.remove(team);
    });
    widget.onRemoveTeam(team);
    AppLogger.debug('Team removed: ${team.name}');
    AppLogger.debug('Total selected teams: ${_selectedTeams.length}');
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building InviteesSelectorScreen');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        leading: IconButton(
          icon: CustomIcon.arrowBack,
          onPressed: () {
            AppLogger.debug('Back button pressed');
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: CustomColor.black,
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.debug('Done button pressed');
              AppLogger.debug(
                  'Returning selected invitees: ${_selectedInvitees.length}');
              AppLogger.debug(
                  'Returning selected teams: ${_selectedTeams.length}');
              Navigator.of(context).pop({
                'invitees': _selectedInvitees,
                'teams': _selectedTeams,
              });
            },
            child: Text(
              CustomString.done,
              style: CustomTextStyle.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: CustomColor.customPurple,
              ),
            ),
          ),
        ],
      ),
      body: InviteesField(
        searchController: widget.searchController,
        selectedInvitees: _selectedInvitees,
        selectedTeams: _selectedTeams,
        searchResults: widget.searchResults,
        isSearching: widget.isSearching,
        onAddInvitee: _onAddInvitee,
        onRemoveInvitee: _onRemoveInvitee,
        onAddTeam: _onAddTeam,
        onRemoveTeam: _onRemoveTeam,
        onSelectEverybody: widget.onSelectEverybody,
        onSearch: (query) {
          AppLogger.debug('Performing search with query: $query');
          widget.onSearch(query);
          setState(() {
            // This will trigger a rebuild of the widget with the updated search results
          });
        },
        isEverybodySelected: widget.isEverybodySelected,
      ),
    );
  }
}
