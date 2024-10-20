import 'dart:typed_data';
import 'package:cfq_dev/enums/moods.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import 'package:cfq_dev/utils/styles/text_styles.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as model;
import '../models/turn_event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';
import 'package:uuid/uuid.dart';
import '../providers/storage_methods.dart';
import '../models/team.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../screens/invitees_selector_screen.dart';
import '../view_models/invitees_selector_view_model.dart';
import '../widgets/atoms/chips/mood_chip.dart';
import '../widgets/atoms/buttons/custom_button.dart';

class CreateTurnViewModel extends ChangeNotifier
    implements InviteesSelectorViewModel {
  // Controllers for form fields
  final TextEditingController turnNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TextEditingController inviteesController = TextEditingController();
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;
  List<model.User> _previousSelectedInvitees = [];
  List<Team> _previousSelectedTeamInvitees = [];
  bool _previousIsEverybodySelected = false;

  bool _isEverybodySelected = false;
  bool get isEverybodySelected => _isEverybodySelected;

  // Image
  Uint8List? _turnImage;
  Uint8List? get turnImage => _turnImage;

  // Invitees
  List<model.User> _selectedInvitees = [];
  List<model.User> get selectedInvitees => _selectedInvitees;

  List<Team> _userTeams = [];
  List<Team> get userTeams => _userTeams;

  List<Team> _selectedTeamInvitees = [];
  List<Team> get selectedTeamInvitees => _selectedTeamInvitees;

  // Search
  final TextEditingController searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // Selected DateTime and Moods
  DateTime? _selectedDateTime;
  DateTime? get selectedDateTime => _selectedDateTime;

  List<String>? _selectedMoods;
  List<String>? get selectedMoods => _selectedMoods;

  // Status Messages
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Current User
  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  // Friends List
  List<model.User> _friendsList = [];
  List<model.User> get friendsList => _friendsList;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _showEverybodyOption = true;
  bool get showEverybodyOption => _showEverybodyOption;

  CreateTurnViewModel({this.prefillTeam, this.prefillMembers}) {
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    await _initializeCurrentUser();
    await fetchUserTeams();
    performSearch(CustomString.emptyString);
    searchController.addListener(() {
      performSearch(searchController.text);
    });
    if (prefillTeam != null) {
      _initializePrefillData();
      _removePrefillDataFromSearchResults();
    }
  }

  void _initializePrefillData() {
    if (prefillTeam != null) {
      _selectedTeamInvitees.add(prefillTeam!);
      for (var member in prefillMembers ?? []) {
        if (member.uid != _currentUser?.uid &&
            !_selectedInvitees.any((invitee) => invitee.uid == member.uid)) {
          _selectedInvitees.add(member);
        }
      }
      _updateInviteesControllerText();
    }
  }

  void _removePrefillDataFromSearchResults() {
    if (prefillTeam != null) {
      _searchResults.removeWhere(
          (result) => result is Team && result.uid == prefillTeam!.uid);
      _searchResults.removeWhere((result) =>
          result is model.User &&
          prefillMembers!.map((member) => member.uid).contains(result.uid));
      notifyListeners();
    }
  }

  Future<void> _initializeCurrentUser() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch current user data
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      _currentUser = model.User.fromSnap(userSnapshot);

      await fetchUserTeams();

      // Fetch friends data
      List friendsUids = _currentUser!.friends;
      if (friendsUids.isNotEmpty) {
        QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: friendsUids)
            .get();

        _friendsList = friendsSnapshot.docs
            .map((doc) => model.User.fromSnap(doc))
            .toList();
      } else {
        _friendsList = [];
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing current user: $e');
      _errorMessage = CustomString.failedToInitializeUserData;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    turnNameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickTurnImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        Uint8List imageBytes = await image.readAsBytes();
        // Optionally compress the image here if needed
        _turnImage = imageBytes;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error picking cfq image: $e');
      _errorMessage = CustomString.failedToPickImage;
      notifyListeners();
    }
  }

  Future<void> fetchUserTeams() async {
    try {
      QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('members', arrayContains: _currentUser!.uid)
          .get();

      _userTeams = teamsSnapshot.docs.map((doc) => Team.fromSnap(doc)).toList();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching user teams: $e');
      _errorMessage = CustomString.failedToFetchUserTeams;
      notifyListeners();
    }
  }

  void _onSearchChanged() {
    performSearch(searchController.text);
  }

  Future<void> performSearch(String query) async {
    _isSearching = true;
    notifyListeners();

    try {
      final queryLower = query.toLowerCase();

      _showEverybodyOption = query.isEmpty;

      if (_isEverybodySelected) {
        // If everybody is selected, only show teams in search results
        _searchResults = _userTeams
            .where((team) =>
                team.name.toLowerCase().startsWith(queryLower) &&
                !_selectedTeamInvitees.contains(team))
            .toList();
      } else {
        if (query.isEmpty) {
          _searchResults = [
            ..._userTeams,
            ..._friendsList.where((user) =>
                !_selectedInvitees.any((f) => f.uid == user.uid) &&
                user.uid != _currentUser?.uid)
          ];
        } else {
          List<Team> filteredTeams = _userTeams
              .where((team) =>
                  team.name.toLowerCase().startsWith(queryLower) &&
                  !_selectedTeamInvitees.contains(team))
              .toList();

          List<model.User> filteredUsers = _friendsList.where((user) {
            final searchKeyLower = user.searchKey.toLowerCase();
            return searchKeyLower.startsWith(queryLower) &&
                !_selectedInvitees.any((f) => f.uid == user.uid) &&
                user.uid != _currentUser?.uid;
          }).toList();

          _searchResults = [...filteredTeams, ...filteredUsers];
        }
      }
    } catch (e) {
      AppLogger.error('Error while searching: $e');
      _errorMessage = CustomString.failedToPerformSearch;
    }

    _isSearching = false;
    notifyListeners();
  }

  void selectEverybody() {
    if (!_isEverybodySelected) {
      _selectedInvitees = List.from(_friendsList);
      _isEverybodySelected = true;
    } else {
      removeEverybody();
    }
    performSearch(searchController.text);
    notifyListeners();
  }

  void removeEverybody() {
    _selectedInvitees.clear();
    _isEverybodySelected = false;
    performSearch(searchController.text);
    notifyListeners();
  }

  // Update the addInvitee method
  void addInvitee(model.User invitee) {
    _selectedInvitees.add(invitee);
    _searchResults.removeWhere(
        (result) => result is model.User && result.uid == invitee.uid);
    notifyListeners();
  }

  void removeInvitee(model.User invitee) {
    _selectedInvitees.remove(invitee);

    // Check if the invitee is part of any selected teams
    for (var team in _selectedTeamInvitees.toList()) {
      if (team.members.contains(invitee.uid)) {
        _selectedTeamInvitees.remove(team);
      }
    }

    // If any invitee is removed, "Everybody" should be deselected
    _isEverybodySelected = false;

    performSearch(searchController.text);

    notifyListeners();
  }

  void addTeam(Team team) {
    if (!_selectedTeamInvitees.contains(team)) {
      _selectedTeamInvitees.add(team);
      _searchResults
          .removeWhere((result) => result is Team && result.uid == team.uid);

      // Convert member IDs to User objects and add them to _selectedInvitees
      List<model.User> teamMembers = _friendsList
          .where((friend) =>
              team.members.contains(friend.uid) &&
              friend.uid != _currentUser?.uid)
          .toList();

      // Add team members to _selectedInvitees without duplicates
      for (var member in teamMembers) {
        if (!_selectedInvitees.any((invitee) => invitee.uid == member.uid)) {
          _selectedInvitees.add(member);
        }
      }

      _searchResults.removeWhere((result) =>
          result is model.User && team.members.contains(result.uid));
      notifyListeners();
    }
  }

  void removeTeam(Team team) {
    _selectedTeamInvitees.remove(team);

    // "Everybody" should be deselected when a team is removed
    _isEverybodySelected = false;

    performSearch(searchController.text);

    notifyListeners();
  }

  // Date-Time Picker
  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        notifyListeners();
      }
    }
  }

  // Moods Selection
  Future<void> selectMoods(BuildContext context) async {
    List<String> tempSelectedMoods = List<String>.from(_selectedMoods ?? []);
    await showDialog<List<String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Stack(
                children: [
                  Center(
                    child: Text(
                      CustomString.whatMood,
                      style: CustomTextStyle.bigBody1,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: const Icon(Icons.close,
                          color: CustomColor.customWhite),
                    ),
                  ),
                ],
              ),
              backgroundColor: CustomColor.customBlack,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.maxFinite,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: CustomMood.moods.map((mood) {
                        return MoodChip(
                          icon: mood.icon,
                          label: mood.label,
                          isSelected: tempSelectedMoods.contains(mood.label),
                          onTap: () {
                            setState(() {
                              if (tempSelectedMoods.contains(mood.label)) {
                                tempSelectedMoods.remove(mood.label);
                              } else {
                                tempSelectedMoods.add(mood.label);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
              actions: [
                Center(
                  child: CustomButton(
                    label: CustomString.done,
                    color: CustomColor.customPurple,
                    borderRadius: 15,
                    onTap: () =>
                        Navigator.of(dialogContext).pop(tempSelectedMoods),
                    width: 140, // Adjust this value to make the button smaller
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedMoods) {
      if (selectedMoods != null) {
        _selectedMoods = selectedMoods;
        notifyListeners();
      }
    });
  }

  // Create TURN
  Future<void> createTurn() async {
    // Validate required fields
    if (_turnImage == null) {
      _errorMessage = CustomString.pleaseSelectAnImage;
      notifyListeners();
      return;
    }

    if (turnNameController.text.isEmpty || descriptionController.text.isEmpty) {
      _errorMessage = CustomString.pleaseFillAllRequiredFields;
      notifyListeners();
      return;
    }

    if (_selectedDateTime == null) {
      _errorMessage = CustomString.pleaseSelectDateAndTime;
      notifyListeners();
      return;
    }

    if (_selectedMoods == null || _selectedMoods!.isEmpty) {
      _errorMessage = CustomString.pleaseSelectAtLeastOneMood;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Upload image to Firebase Storage
      String turnImageUrl = await StorageMethods()
          .uploadImageToStorage('turnImages', _turnImage!, false);

      // Generate unique TURN ID
      String turnId = const Uuid().v1();

      // Generate unique channel ID
      String channelId = const Uuid().v1();

      // Get current user UID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Collect invitee UIDs (excluding current user)
      List<String> inviteeUids =
          _selectedInvitees.map((user) => user.uid).toList();

      // Create TURN object
      Turn turn = Turn(
          name: turnNameController.text.trim(),
          description: descriptionController.text.trim(),
          moods: _selectedMoods!,
          uid: currentUserId,
          username: _currentUser!.username,
          eventId: turnId,
          datePublished: DateTime.now(),
          eventDateTime: _selectedDateTime!,
          imageUrl: turnImageUrl,
          profilePictureUrl: _currentUser!.profilePictureUrl,
          where: locationController.text.trim(),
          address: addressController.text.trim(),
          organizers: [currentUserId], // Assuming current user is the organizer
          invitees: inviteeUids,
          teamInvitees: _selectedTeamInvitees.map((team) => team.uid).toList(),
          attending: [],
          notSureAttending: [],
          notAttending: [],
          notAnswered: [],
          channelId: channelId);

      // Save TURN to Firestore
      await FirebaseFirestore.instance
          .collection('turns')
          .doc(turnId)
          .set(turn.toJson());

      // Update users' postedTurns
      await _updateUserPosts(currentUserId, turnId);

      // Update users' invitedTurns
      await _updateInviteesTurns(inviteeUids, turnId);

      // Update teams' invitedTurns
      await _updateTeamInviteesTurns(
          _selectedTeamInvitees.map((team) => team.uid).toList(), turnId);

      _successMessage = CustomString.successCreatingTurn;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error creating TURN: $e');
      _errorMessage = CustomString.errorCreatingTurn;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update 'posted_turns' field for user
  Future<void> _updateUserPosts(String currentUserId, String turnId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      batch.update(userRef, {
        'postedTurns': FieldValue.arrayUnion([turnId])
      });

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error updating users\' turns: $e');
      rethrow; // Re-throw the error to be caught in createTurn()
    }
  }

  @override
  void revertSelections() {
    _selectedInvitees = List.from(_previousSelectedInvitees);
    _selectedTeamInvitees = List.from(_previousSelectedTeamInvitees);
    _isEverybodySelected = _previousIsEverybodySelected;
    _updateInviteesControllerText();
    notifyListeners();
  }

  // Update 'turns' field for invitees
  Future<void> _updateInviteesTurns(
      List<String> inviteesIds, String turnId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String uid in inviteesIds) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        batch.update(userRef, {
          'invitedTurns': FieldValue.arrayUnion([turnId])
        });
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error updating users\' turns: $e');
      rethrow; // Re-throw the error to be caught in createTurn()
    }
  }

  // Update 'invitedTurns' field for team invitees
  Future<void> _updateTeamInviteesTurns(
      List<String> teamInviteesIds, String turnId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String teamId in teamInviteesIds) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('teams').doc(teamId);
        batch.update(userRef, {
          'invitedTurns': FieldValue.arrayUnion([turnId])
        });
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error updating users\' cfqs: $e');
      rethrow; // Re-throw the error to be caught in createCfq()
    }
  }

  // Method to reset status messages
  void resetStatus() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> openInviteesSelectorScreen(BuildContext context) async {
    // Store the current state before opening the selector screen
    _previousSelectedInvitees = List.from(_selectedInvitees);
    _previousSelectedTeamInvitees = List.from(_selectedTeamInvitees);
    _previousIsEverybodySelected = _isEverybodySelected;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChangeNotifierProvider<InviteesSelectorViewModel>.value(
          value: this,
          child: const InviteesSelectorScreen(),
        ),
      ),
    );

    if (result != null) {
      _selectedInvitees = result['invitees'];
      _selectedTeamInvitees = result['teams'];
      _isEverybodySelected = result['isEverybodySelected'];
    } else {
      revertSelections();
    }
    _updateInviteesControllerText();
    notifyListeners();
  }

  void _updateInviteesControllerText() {
    List<String> inviteeNames =
        _selectedTeamInvitees.map((team) => team.name).toList();
    inviteeNames.addAll(_selectedInvitees.map((user) => user.username));
    inviteesController.text = inviteeNames.join(', ');
  }

  @override
  void toggleInvitee(model.User invitee) {
    if (_selectedInvitees.contains(invitee)) {
      removeInvitee(invitee);
    } else {
      addInvitee(invitee);
    }
  }

  @override
  void toggleTeam(Team team) {
    if (_selectedTeamInvitees.contains(team)) {
      removeTeam(team);
    } else {
      addTeam(team);
    }
  }

  @override
  void toggleEverybody() {
    if (_isEverybodySelected) {
      removeEverybody();
    } else {
      selectEverybody();
    }
  }
}
