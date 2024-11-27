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
import '../utils/utils.dart';
import 'package:uuid/uuid.dart';
import '../providers/storage_methods.dart';
import '../models/team.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../screens/invitees_selector_screen.dart';
import '../view_models/invitees_selector_view_model.dart';
import '../widgets/atoms/chips/mood_chip.dart';
import '../widgets/atoms/buttons/custom_button.dart';
import '../providers/conversation_service.dart';
import '../widgets/atoms/dates/custom_date_time_range_picker.dart';
import '../utils/date_time_utils.dart';
import '../widgets/atoms/address_selectors/google_places_address_selector.dart';

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

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  final ConversationService _conversationService = ConversationService();

  DateTime? _selectedEndDateTime;
  DateTime? get selectedEndDateTime => _selectedEndDateTime;

  final bool isEditing;
  final Turn? turnToEdit;

  // Add location field
  Location? _location;
  Location? get location => _location;

  bool _showPredictions = true;
  bool get showPredictions => _showPredictions;

  CreateTurnViewModel({
    this.prefillTeam,
    this.prefillMembers,
    this.isEditing = false,
    this.turnToEdit,
  }) {
    if (isEditing && turnToEdit != null) {
      _initializeEditMode();
    }
    _initializeViewModel();
  }

  void _initializeEditMode() {
    turnNameController.text = turnToEdit!.name;
    descriptionController.text = turnToEdit!.description;
    locationController.text = turnToEdit!.where;
    _selectedDateTime = turnToEdit!.eventDateTime;
    _selectedEndDateTime = turnToEdit!.endDateTime;
    _selectedMoods = turnToEdit!.moods;
    _location = turnToEdit!.location;
    _showPredictions = false;

    // Fetch Turn data including invitees
    _fetchTurnData();
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

  Future<void> _fetchTurnData() async {
    try {
      DocumentSnapshot turnDoc = await FirebaseFirestore.instance
          .collection('turns')
          .doc(turnToEdit!.eventId)
          .get();

      Map<String, dynamic> data = turnDoc.data() as Map<String, dynamic>;

      // Fetch invitees
      List<String> inviteeIds = List<String>.from(data['invitees'] ?? []);
      List<String> teamIds = List<String>.from(data['teamInvitees'] ?? []);

      // Fetch invitee user objects
      _selectedInvitees = await Future.wait(inviteeIds.map((id) async {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        return model.User.fromSnap(userDoc);
      }));

      // Fetch team objects
      _selectedTeamInvitees = await Future.wait(teamIds.map((id) async {
        DocumentSnapshot teamDoc =
            await FirebaseFirestore.instance.collection('teams').doc(id).get();
        return Team.fromSnap(teamDoc);
      }));

      _previousSelectedInvitees = List.from(_selectedInvitees);
      _previousSelectedTeamInvitees = List.from(_selectedTeamInvitees);
      _updateInviteesControllerText();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching turn data: $e');
    }
  }

  Future<void> updateTurn() async {
    // Validate required fields
    if (turnNameController.text.isEmpty) {
      _errorMessage = CustomString.pleaseEnterTurnName;
      notifyListeners();
      return;
    }

    if (turnNameController.text.length > 30) {
      _errorMessage = CustomString.maxLengthTurn;
      notifyListeners();
      return;
    }

    if (_selectedDateTime == null) {
      _errorMessage = CustomString.pleaseSelectDateAndTime;
      notifyListeners();
      return;
    }

    if (locationController.text.isEmpty) {
      _errorMessage = CustomString.pleaseEnterWhere;
      notifyListeners();
      return;
    }

    if (_selectedInvitees.isEmpty) {
      _errorMessage = CustomString.pleaseSelectAtLeastOneInvitee;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? turnImageUrl = turnToEdit!.imageUrl;

      // Only upload new image if it was changed
      if (_turnImage != null) {
        turnImageUrl = await StorageMethods()
            .uploadImageToStorage('turns', _turnImage!, true);
      }

      // Get previous invitees from Firestore
      DocumentSnapshot turnDoc = await FirebaseFirestore.instance
          .collection('turns')
          .doc(turnToEdit!.eventId)
          .get();
      Map<String, dynamic> data = turnDoc.data() as Map<String, dynamic>;
      List<String> previousInvitees = List<String>.from(data['invitees'] ?? []);

      await _removeEventFromUninvitedUsers(
        _selectedInvitees.map((user) => user.uid).toList(),
        previousInvitees,
        turnToEdit!.eventId,
      );

      // Notify new invitees
      await _notifyNewInvitees(
        _selectedInvitees.map((user) => user.uid).toList(),
        previousInvitees,
        turnToEdit!.eventId,
        turnNameController.text.trim(),
        turnImageUrl,
      );

      // Update conversation if channelId exists
      String? channelId = data['channelId'] ?? turnToEdit!.channelId;
      if (channelId != null) {
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(channelId)
            .update({
          'name': turnNameController.text.trim(),
          'imageUrl': turnImageUrl,
        });
      }

      // Update turn object
      Turn updatedTurn = Turn(
        name: turnNameController.text.trim(),
        description: descriptionController.text.trim(),
        moods: _selectedMoods,
        uid: turnToEdit!.uid,
        username: turnToEdit!.username,
        eventId: turnToEdit!.eventId,
        datePublished: turnToEdit!.datePublished,
        eventDateTime: _selectedDateTime!,
        endDateTime: _selectedEndDateTime,
        imageUrl: turnImageUrl,
        profilePictureUrl: turnToEdit!.profilePictureUrl,
        where: locationController.text.trim(),
        location: _location,
        organizers: turnToEdit!.organizers,
        invitees: _selectedInvitees.map((user) => user.uid).toList(),
        teamInvitees: _selectedTeamInvitees.map((team) => team.uid).toList(),
        channelId: data['channelId'] ?? turnToEdit!.channelId,
        attending: List<String>.from(data['attending']),
        notSureAttending: List<String>.from(data['notSureAttending']),
        notAnswered: List<String>.from(data['notAnswered']),
        notAttending: List<String>.from(data['notAttending']),
      );

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('turns')
          .doc(turnToEdit!.eventId)
          .update(updatedTurn.toJson());

      // Update invitees
      await _updateInviteesTurns(
          _selectedInvitees.map((user) => user.uid).toList(),
          turnToEdit!.eventId);
      await _updateTeamInviteesTurns(
          _selectedTeamInvitees.map((team) => team.uid).toList(),
          turnToEdit!.eventId);

      _successMessage = 'TURN mis à jour avec succès';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating TURN: $e');
      _errorMessage = 'Erreur lors de la mise à jour du TURN';
      _isLoading = false;
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

  Future<void> pickTurnImage(context) async {
    try {
      final ImageSource? source = await showImageSourceDialog(context);
      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);

        if (image != null) {
          Uint8List imageBytes = await image.readAsBytes();
          // Optionally compress the image here if needed
          _turnImage = imageBytes;
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error('Error picking turn image: $e');
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
    try {
      final now = DateTimeUtils.roundToNextFiveMinutes(DateTime.now());

      // If current selected date is in the past, update it
      if (_selectedDateTime == null || _selectedDateTime!.isBefore(now)) {
        _selectedDateTime = now;
      }

      await showDialog(
        context: context,
        builder: (context) => CustomDateTimeRangePicker(
          startInitialDate: _selectedDateTime,
          endInitialDate: _selectedEndDateTime,
          onDateTimeSelected: (start, end) {
            // Do one final check before accepting the dates
            final currentTime =
                DateTimeUtils.roundToNextFiveMinutes(DateTime.now());
            if (start.isBefore(currentTime)) {
              _errorMessage = CustomString.dateTimeInPast;
              return;
            }

            _selectedDateTime = start;
            _selectedEndDateTime = end;
            notifyListeners();
          },
        ),
      );
    } catch (e) {
      AppLogger.error('Error selecting date time: $e');
      _errorMessage = CustomString.someErrorOccurred;
      notifyListeners();
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
    if (turnNameController.text.isEmpty) {
      _errorMessage = CustomString.pleaseEnterTurnName;
      notifyListeners();
      return;
    }

    if (turnNameController.text.length > 30) {
      _errorMessage = CustomString.maxLengthTurn;
      notifyListeners();
      return;
    }

    if (_selectedDateTime == null) {
      _errorMessage = CustomString.pleaseSelectDateAndTime;
      notifyListeners();
      return;
    }

    if (locationController.text.isEmpty) {
      _errorMessage = CustomString.pleaseEnterWhere;
      notifyListeners();
      return;
    }

    if (_selectedInvitees.isEmpty && _selectedTeamInvitees.isEmpty) {
      _errorMessage = CustomString.pleaseSelectAtLeastOneInvitee;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? turnImageUrl;
      if (_turnImage != null) {
        turnImageUrl = await StorageMethods()
            .uploadImageToStorage('turnImages', _turnImage!, false);
      }

      String turnId = const Uuid().v1();
      String channelId = const Uuid().v1();
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      List<String> inviteeUids =
          _selectedInvitees.map((user) => user.uid).toList();

      // Create turn object with the channelId
      Turn turn = Turn(
        name: turnNameController.text.trim(),
        description: descriptionController.text.trim(),
        moods: _selectedMoods,
        uid: currentUserId,
        username: _currentUser!.username,
        eventId: turnId,
        datePublished: DateTime.now(),
        eventDateTime: _selectedDateTime!,
        endDateTime: _selectedEndDateTime,
        imageUrl: turnImageUrl,
        profilePictureUrl: _currentUser!.profilePictureUrl,
        where: locationController.text.trim(),
        location: _location,
        organizers: [currentUserId],
        invitees: _selectedInvitees.map((user) => user.uid).toList(),
        teamInvitees: _selectedTeamInvitees.map((team) => team.uid).toList(),
        channelId: channelId, // Add channelId to the turn object
        notAnswered: [
          ...inviteeUids
        ], // Add all invitees to notAnswered initially
        attending: [currentUserId],
        notSureAttending: [],
        notAttending: [],
      );

      AppLogger.debug(turnNameController.text.trim());
      AppLogger.debug(turnImageUrl.toString());

      await _createEventInvitationNotifications(
        _selectedInvitees.map((user) => user.uid).toList(),
        turnId,
        turnNameController.text,
        turnImageUrl ?? '',
      );

      // Create conversation first
      await _conversationService.createConversation(
        channelId,
        turnNameController.text.trim(),
        turnImageUrl ?? '',
        [...inviteeUids, currentUserId], // Include all members
        currentUserId,
        _currentUser!.username,
        _currentUser!.profilePictureUrl,
      );

      // Add conversation to current user's conversations
      model.ConversationInfo conversationInfo = model.ConversationInfo(
        conversationId: channelId,
        unreadMessagesCount: 0,
      );

      // Update current user's conversations in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'conversations': FieldValue.arrayUnion([conversationInfo.toMap()]),
      });

      // Save turn to Firestore
      await FirebaseFirestore.instance
          .collection('turns')
          .doc(turnId)
          .set(turn.toJson());

      final userRef = _firestore.collection('users').doc(_currentUser!.uid);
      final userDoc = await userRef.get();
      final userData = userDoc.data()!;

      final batch = _firestore.batch();

      // Update user's attending status
      Map<String, dynamic> attendingStatus =
          Map<String, dynamic>.from(userData['attendingStatus'] ?? {});

      attendingStatus[turnId] = 'attending';
      batch.update(userRef, {'attendingStatus': attendingStatus});

      await batch.commit();

      // Update users' postedTurns
      await _updateUserPosts(currentUserId, turnId);

      // Update users' invitedTurns
      await _updateInviteesTurns(inviteeUids, turnId);

      // Update teams' invitedTurns
      await _updateTeamInviteesTurns(
          _selectedTeamInvitees.map((team) => team.uid).toList(), turnId);

      AppLogger.debug('Created turnId : $turnId');

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
    String text = '';
    if (_selectedTeamInvitees.isEmpty) {
      if (_selectedInvitees.length <= 3) {
        List<String> inviteeNames =
            _selectedInvitees.map((user) => user.username).toList();
        text = inviteeNames.join(', ');
      } else {
        List<String> inviteeNames =
            _selectedInvitees.take(3).map((user) => user.username).toList();
        int remainingInviteesCount = _selectedInvitees.length - 3;
        if (remainingInviteesCount == 1) {
          text =
              '${inviteeNames.join(', ')}... et $remainingInviteesCount autre';
        } else {
          text =
              '${inviteeNames.join(', ')}... et $remainingInviteesCount autres';
        }
      }
    } else {
      List<String> teamInviteeNames =
          _selectedTeamInvitees.map((team) => team.name).toList();
      int inviteesCount = _selectedInvitees.length;
      if (_selectedTeamInvitees.length <= 2) {
        text = '${teamInviteeNames.join(', ')} et $inviteesCount invités';
      } else {
        List<String> teamInviteeNames =
            _selectedTeamInvitees.map((team) => team.name).toList();
        int inviteesCount = _selectedInvitees.length;
        text = '${teamInviteeNames.join(', ')}... et $inviteesCount invités';
      }
    }

    inviteesController.text = text;
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

  Future<void> _createEventInvitationNotifications(
    List<String> inviteesIds,
    String eventId,
    String eventName,
    String eventImageUrl,
  ) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String uid in inviteesIds) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // Increment unread notifications count
          batch.update(
            FirebaseFirestore.instance.collection('users').doc(uid),
            {'unreadNotificationsCount': FieldValue.increment(1)},
          );
          String notificationsChannelId = userDoc.get('notificationsChannelId');
          String notificationId = const Uuid().v1();

          DocumentReference notificationRef = FirebaseFirestore.instance
              .collection('notifications')
              .doc(notificationsChannelId)
              .collection('userNotifications')
              .doc(notificationId);

          batch.set(notificationRef, {
            'id': notificationId,
            'timestamp': DateTime.now().toIso8601String(),
            'type': 'eventInvitation',
            'content': {
              'eventId': eventId,
              'eventName': eventName,
              'isTurn': true,
              'eventImageUrl': eventImageUrl,
              'organizerId': _currentUser!.uid,
              'organizerUsername': _currentUser!.username,
              'organizerProfilePictureUrl': _currentUser!.profilePictureUrl,
            }
          });
        }
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error creating event invitation notifications: $e');
      rethrow;
    }
  }

  Future<void> _notifyNewInvitees(
    List<String> currentInvitees,
    List<String> previousInvitees,
    String turnId,
    String turnName,
    String turnImageUrl,
  ) async {
    // Get only new invitees
    List<String> newInvitees = currentInvitees
        .where((invitee) => !previousInvitees.contains(invitee))
        .toList();

    if (newInvitees.isNotEmpty) {
      await _createEventInvitationNotifications(
        newInvitees,
        turnId,
        turnName,
        turnImageUrl,
      );
    }
  }

  Future<void> _removeEventFromUninvitedUsers(
    List<String> currentInvitees,
    List<String> previousInvitees,
    String turnId,
  ) async {
    try {
      // Get users who were uninvited
      List<String> uninvitedUsers = previousInvitees
          .where((invitee) => !currentInvitees.contains(invitee))
          .toList();

      if (uninvitedUsers.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (String uid in uninvitedUsers) {
          DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(uid);
          batch.update(userRef, {
            'invitedTurns': FieldValue.arrayRemove([turnId])
          });
        }

        await batch.commit();
      }
    } catch (e) {
      AppLogger.error('Error removing turn from uninvited users: $e');
      rethrow;
    }
  }

  void onAddressSelected(PlaceData placeData) {
    locationController.text = placeData.address;
    _location = placeData.latitude != null && placeData.longitude != null
        ? Location(
            latitude: placeData.latitude!,
            longitude: placeData.longitude!,
          )
        : null;
    notifyListeners();
  }

  Future<List<model.User>> _fetchUsers(List<String> userIds) async {
    try {
      return await Future.wait(userIds.map((id) async {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(id).get();
        return model.User.fromSnap(userDoc);
      }));
    } catch (e) {
      AppLogger.error('Error fetching users: $e');
      return [];
    }
  }

  Future<List<Team>> _fetchTeams(List<String> teamIds) async {
    try {
      return await Future.wait(teamIds.map((id) async {
        DocumentSnapshot teamDoc =
            await _firestore.collection('teams').doc(id).get();
        return Team.fromSnap(teamDoc);
      }));
    } catch (e) {
      AppLogger.error('Error fetching teams: $e');
      return [];
    }
  }
}
