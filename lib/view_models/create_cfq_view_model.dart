import 'dart:typed_data';
import 'package:cfq_dev/enums/moods.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart' as model;
import '../models/cfq_event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';
import 'package:uuid/uuid.dart';
import '../providers/storage_methods.dart';
import '../models/team.dart';

class CreateCfqViewModel extends ChangeNotifier {
  // Controllers for form fields
  final TextEditingController cfqNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController whenController = TextEditingController();
  TextEditingController inviteesController = TextEditingController();
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;

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

  final List<Team> _selectedTeamInvitees = [];
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

  CreateCfqViewModel({this.prefillTeam, this.prefillMembers}) {
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    await _initializeCurrentUser();
    await fetchUserTeams();
    performSearch(CustomString.emptyString);
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
      _errorMessage = 'Failed to initialize user data.';
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
      _errorMessage = 'Failed to fetch user teams.';
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
      _errorMessage = 'Failed to perform search.';
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

  // Update the removeInvitee method
  void removeInvitee(model.User invitee) {
    _selectedInvitees.remove(invitee);
    performSearch(searchController.text);
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
    _selectedInvitees
        .removeWhere((invitee) => team.members.contains(invitee.uid));
    performSearch(searchController.text);
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
    cfqNameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    whenController.dispose();
    super.dispose();
  }

  // Image Picker
  Future<void> pickCfqImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        Uint8List imageBytes = await image.readAsBytes();
        // Optionally compress the image here if needed
        _cfqImage = imageBytes;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error picking cfq image: $e');
      _errorMessage = 'Failed to pick image.';
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
              title: const Text(CustomString.whatMood),
              content: SingleChildScrollView(
                child: Column(
                  children: CustomMood.moods.map((mood) {
                    return CheckboxListTile(
                      title: Text(mood),
                      value: tempSelectedMoods.contains(mood),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedMoods.add(mood);
                          } else {
                            tempSelectedMoods.remove(mood);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(tempSelectedMoods);
                  },
                  child: const Text(CustomString.ok),
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
    if (_cfqImage == null) {
      _errorMessage = 'Please select an image.';
      notifyListeners();
      return;
    }

    if (cfqNameController.text.isEmpty || descriptionController.text.isEmpty) {
      _errorMessage = 'Please fill all required fields.';
      notifyListeners();
      return;
    }

    if (_selectedMoods == null || _selectedMoods!.isEmpty) {
      _errorMessage = 'Please select at least one mood.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Upload image to Firebase Storage
      String cfqImageUrl = await StorageMethods()
          .uploadImageToStorage('cfqImages', _cfqImage!, false);

      // Generate unique cfq ID
      String cfqId = const Uuid().v1();

      // Get current user UID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Collect invitee UIDs (excluding current user)
      List<String> inviteeUids =
          _selectedInvitees.map((user) => user.uid).toList();

      // Ensure current user is included
      if (!inviteeUids.contains(currentUserId)) {
        inviteeUids.add(currentUserId);
      }

      // Create cfq object
      Cfq cfq = Cfq(
        name: cfqNameController.text.trim(),
        description: descriptionController.text.trim(),
        moods: _selectedMoods!,
        uid: currentUserId,
        username: _currentUser!.username,
        eventId: cfqId,
        datePublished: DateTime.now(),
        when: whenController.text.trim(),
        imageUrl: cfqImageUrl,
        profilePictureUrl: _currentUser!.profilePictureUrl,
        where: locationController.text.trim(),
        organizers: [currentUserId],
        invitees: _selectedInvitees.map((user) => user.uid).toList(),
        teamInvitees: _selectedTeamInvitees.map((team) => team.uid).toList(),
      );

      // Save cfq to Firestore
      await FirebaseFirestore.instance
          .collection('cfqs')
          .doc(cfqId)
          .set(cfq.toJson());

      // Update users' postedCfqs
      await _updateUserPosts(currentUserId, cfqId);

      // Update users' invitedCfqs
      await _updateInviteesCfqs(inviteeUids, cfqId);

      // Update teams' invitedCfqs
      await _updateTeamInviteesCfqs(
          _selectedTeamInvitees.map((team) => team.uid).toList(), cfqId);

      _successMessage = 'CFQ created successfully!';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error creating cfq: $e');
      _errorMessage = 'Failed to create cfq. Please try again.';
      _isLoading = false;
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
}
