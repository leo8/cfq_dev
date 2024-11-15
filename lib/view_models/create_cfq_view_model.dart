import 'dart:typed_data';
import 'package:cfq_dev/enums/moods.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:cfq_dev/utils/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart' as model;
import '../models/cfq_event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';
import '../utils/utils.dart';
import 'package:uuid/uuid.dart';
import '../providers/storage_methods.dart';
import '../models/team.dart';
import '../screens/invitees_selector_screen.dart';
import 'package:provider/provider.dart';
import '../view_models/invitees_selector_view_model.dart';
import '../widgets/atoms/chips/mood_chip.dart';
import '../widgets/atoms/buttons/custom_button.dart';
import '../providers/conversation_service.dart';
import '../widgets/atoms/dates/custom_date_time_picker.dart';
import '../utils/date_time_utils.dart';

class CreateCfqViewModel extends ChangeNotifier
    implements InviteesSelectorViewModel {
  // Controllers for form fields
  DateTime? _selectedDateTime;
  DateTime? _selectedEndDateTime;
  DateTime? get selectedDateTime => _selectedDateTime;
  DateTime? get selectedEndDateTime => _selectedEndDateTime;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController whenController = TextEditingController();
  TextEditingController inviteesController = TextEditingController();
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;

  List<model.User> _previousSelectedInvitees = [];
  List<Team> _previousSelectedTeamInvitees = [];
  bool _previousIsEverybodySelected = false;

  // Everybody
  bool _isEverybodySelected = false;
  bool get isEverybodySelected => _isEverybodySelected;

  // Image
  Uint8List? _cfqImage;
  Uint8List? get cfqImage => _cfqImage;

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

  // Selected Moods
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

  final bool isEditing;
  final Cfq? cfqToEdit;

  CreateCfqViewModel({
    this.prefillTeam,
    this.prefillMembers,
    this.isEditing = false,
    this.cfqToEdit,
  }) {
    if (isEditing && cfqToEdit != null) {
      _initializeEditMode();
    }
    _initializeViewModel();
  }

  void _initializeEditMode() {
    whenController.text = cfqToEdit!.when;
    descriptionController.text = cfqToEdit!.description;
    locationController.text = cfqToEdit!.where;
    _selectedDateTime = cfqToEdit!.eventDateTime;
    _selectedEndDateTime = cfqToEdit!.endDateTime;
    _selectedMoods = cfqToEdit!.moods;

    // Fetch CFQ data including invitees
    _fetchCfqData();
  }

  Future<void> _fetchCfqData() async {
    try {
      DocumentSnapshot cfqDoc = await FirebaseFirestore.instance
          .collection('cfqs')
          .doc(cfqToEdit!.eventId)
          .get();

      Map<String, dynamic> data = cfqDoc.data() as Map<String, dynamic>;

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

      _updateInviteesControllerText();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching CFQ data: $e');
    }
  }

  Future<void> updateCfq() async {
    if (whenController.text.isEmpty) {
      _errorMessage = CustomString.pleaseEnterWhen;
      notifyListeners();
      return;
    }

    if (whenController.text.length > 24) {
      _errorMessage = "Le nom du ÇFQ ne peut pas dépasser 24 caractères";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? cfqImageUrl = cfqToEdit!.imageUrl;

      if (_cfqImage != null) {
        cfqImageUrl = await StorageMethods()
            .uploadImageToStorage('cfqs', _cfqImage!, true);
      }

      // Get previous invitees from Firestore
      DocumentSnapshot cfqDoc = await FirebaseFirestore.instance
          .collection('cfqs')
          .doc(cfqToEdit!.eventId)
          .get();
      Map<String, dynamic> data = cfqDoc.data() as Map<String, dynamic>;
      List<String> previousInvitees = List<String>.from(data['invitees'] ?? []);

      // Remove uninvited users
      await _removeEventFromUninvitedUsers(
        _selectedInvitees.map((user) => user.uid).toList(),
        previousInvitees,
        cfqToEdit!.eventId,
      );

      // Update conversation if channelId exists
      String? channelId = data['channelId'] ?? cfqToEdit!.channelId;
      if (channelId != null) {
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(channelId)
            .update({
          'name': 'ÇFQ ${whenController.text.trim().toUpperCase()} ?',
          'imageUrl': cfqImageUrl,
        });
      }

      Cfq updatedCfq = Cfq(
        when: whenController.text.trim(),
        description: descriptionController.text.trim(),
        moods: _selectedMoods,
        uid: cfqToEdit!.uid,
        username: cfqToEdit!.username,
        eventId: cfqToEdit!.eventId,
        datePublished: cfqToEdit!.datePublished,
        eventDateTime: _selectedDateTime,
        endDateTime: _selectedEndDateTime,
        imageUrl: cfqImageUrl,
        profilePictureUrl: cfqToEdit!.profilePictureUrl,
        where: locationController.text.trim(),
        organizers: cfqToEdit!.organizers,
        invitees: _selectedInvitees.map((user) => user.uid).toList(),
        teamInvitees: _selectedTeamInvitees.map((team) => team.uid).toList(),
        channelId: data['channelId'] ?? cfqToEdit!.channelId,
        followingUp: List<String>.from(data['followingUp'] ?? []),
      );

      await FirebaseFirestore.instance
          .collection('cfqs')
          .doc(cfqToEdit!.eventId)
          .update(updatedCfq.toJson());

      // Notify new invitees
      await _notifyNewInvitees(
        _selectedInvitees.map((user) => user.uid).toList(),
        previousInvitees,
        cfqToEdit!.eventId,
        whenController.text.trim(),
        cfqImageUrl,
      );

      await _updateInviteesCfqs(
          _selectedInvitees.map((user) => user.uid).toList(),
          cfqToEdit!.eventId);
      await _updateTeamInviteesCfqs(
          _selectedTeamInvitees.map((team) => team.uid).toList(),
          cfqToEdit!.eventId);

      _successMessage = 'CFQ mis à jour avec succès';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating CFQ: $e');
      _errorMessage = 'Erreur lors de la mise à jour du CFQ';
      _isLoading = false;
      notifyListeners();
    }
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

      // Update _showEverybodyOption based on whether the search query is empty
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
      notifyListeners();
    }

    _isSearching = false;
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

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    whenController.dispose();
    super.dispose();
  }

  // Image Picker
  Future<void> pickCfqImage(context) async {
    try {
      final ImageSource? source = await showImageSourceDialog(context);
      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);

        if (image != null) {
          Uint8List imageBytes = await image.readAsBytes();
          // Optionally compress the image here if needed
          _cfqImage = imageBytes;
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error('Error picking cfq image: $e');
      _errorMessage = CustomString.failedToPickImage;
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
                    child: Text(CustomString.whatMood,
                        style: CustomTextStyle.bigBody1),
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

  // Create cfq
  Future<void> createCfq() async {
    // Validate required fields
    if (whenController.text.isEmpty) {
      _errorMessage = CustomString.pleaseEnterWhen;
      notifyListeners();
      return;
    }

    if (whenController.text.length > 24) {
      _errorMessage = "Le nom du ÇFQ ne peut pas dépasser 24 caractères";
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
      String? cfqImageUrl;
      if (_cfqImage != null) {
        cfqImageUrl = await StorageMethods()
            .uploadImageToStorage('cfqImages', _cfqImage!, false);
      }

      String cfqId = const Uuid().v1();
      String channelId = const Uuid().v1();
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      List<String> inviteeUids =
          _selectedInvitees.map((user) => user.uid).toList();

      // Create cfq object with the channelId
      Cfq cfq = Cfq(
        when: whenController.text.trim(),
        description: descriptionController.text.trim(),
        moods: _selectedMoods,
        uid: currentUserId,
        username: _currentUser!.username,
        followingUp: [],
        eventId: cfqId,
        datePublished: DateTime.now(),
        eventDateTime: _selectedDateTime,
        endDateTime: _selectedEndDateTime,
        imageUrl: cfqImageUrl,
        profilePictureUrl: _currentUser!.profilePictureUrl,
        where: locationController.text.trim(),
        organizers: [currentUserId],
        invitees: _selectedInvitees.map((user) => user.uid).toList(),
        teamInvitees: _selectedTeamInvitees.map((team) => team.uid).toList(),
        channelId: channelId,
      );

      await _createEventInvitationNotifications(
        _selectedInvitees.map((user) => user.uid).toList(),
        cfqId,
        'ÇFQ ${whenController.text.toUpperCase()} ?',
        cfqImageUrl ?? '',
      );

      // Create conversation first
      await _conversationService.createConversation(
        channelId,
        'ÇFQ ${whenController.text.trim().toUpperCase()} ?',
        cfqImageUrl ?? '',
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

      // Save cfq to Firestore
      await FirebaseFirestore.instance
          .collection('cfqs')
          .doc(cfqId)
          .set(cfq.toJson());

      // Update users' postedCfqs
      await _updateUserPosts(currentUserId, cfqId);

      AppLogger.warning(inviteeUids.length.toString());
      // Update users' invitedCfqs
      await _updateInviteesCfqs(inviteeUids, cfqId);

      // Update teams' invitedCfqs
      await _updateTeamInviteesCfqs(
          _selectedTeamInvitees.map((team) => team.uid).toList(), cfqId);

      _successMessage = CustomString.successCreatingCfq;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error creating cfq: $e');
      _errorMessage = CustomString.errorCreatingCfq;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDateTime(BuildContext context) async {
    try {
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

  // Update 'postedCfqs' field for user
  Future<void> _updateUserPosts(String currentUserId, String cfqId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      batch.update(userRef, {
        'postedCfqs': FieldValue.arrayUnion([cfqId])
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

  // Update 'invitedCfqs' field for invitees
  Future<void> _updateInviteesCfqs(
      List<String> inviteesIds, String cfqId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String uid in inviteesIds) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        batch.update(userRef, {
          'invitedCfqs': FieldValue.arrayUnion([cfqId])
        });
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error updating users\' cfqs: $e');
      rethrow; // Re-throw the error to be caught in createCfq()
    }
  }

  // Update 'invitedCfqs' field for team invitees
  Future<void> _updateTeamInviteesCfqs(
      List<String> teamInviteesIds, String cfqId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String teamId in teamInviteesIds) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('teams').doc(teamId);
        batch.update(userRef, {
          'invitedCfqs': FieldValue.arrayUnion([cfqId])
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
              'isTurn': false,
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
    String cfqId,
    String cfqName,
    String cfqImageUrl,
  ) async {
    // Get only new invitees
    List<String> newInvitees = currentInvitees
        .where((invitee) => !previousInvitees.contains(invitee))
        .toList();

    if (newInvitees.isNotEmpty) {
      await _createEventInvitationNotifications(
        newInvitees,
        cfqId,
        cfqName,
        cfqImageUrl,
      );
    }
  }

  Future<void> _removeEventFromUninvitedUsers(
    List<String> currentInvitees,
    List<String> previousInvitees,
    String cfqId,
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
            'invitedCfqs': FieldValue.arrayRemove([cfqId])
          });
        }

        await batch.commit();
      }
    } catch (e) {
      AppLogger.error('Error removing cfq from uninvited users: $e');
      rethrow;
    }
  }
}
