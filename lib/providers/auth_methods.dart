import 'dart:typed_data';
import 'package:cfq_dev/providers/storage_methods.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cfq_dev/models/user.dart' as model;
import '../utils/styles/string.dart';

// Provider class for authentication-related methods
class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the current user's details from Firestore
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    // Retrieve user document from 'users' collection
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    // Return User model created from Firestore snapshot
    return model.User.fromSnap(snap);
  }

  // Fetch any user's details from Firestore by userId
  Future<model.User> getUserDetailsById(String uid) async {
    // Retrieve user document from 'users' collection
    DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();

    // Return User model created from Firestore snapshot
    return model.User.fromSnap(snap);
  }

  // Update the user's 'isActive' status in Firestore
  Future<void> updateIsActiveStatus(bool isActive) async {
    try {
      String uid = _auth.currentUser!.uid;
      // Update 'isActive' field in the user's document
      await _firestore.collection('users').doc(uid).update({
        'isActive': isActive,
      });
    } catch (e) {
      // Log any errors that occur
      AppLogger.error(e.toString());
    }
  }

  // Sign up a new user
  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      String? location,
      Uint8List? profilePicture,
      DateTime? birthDate,
      required String uid}) async {
    String res = CustomString.someErrorOccurred;

    try {

      // Upload profile picture to storage and get the URL
      String profilePictureUrl = CustomString.emptyString;
      if (profilePicture != null) {

        profilePictureUrl = await StorageMethods()
            .uploadImageToStorage('profilePicture', profilePicture, false);

        // Log the profile picture URL for debugging
        AppLogger.debug('Profile picture URL: $profilePictureUrl');
      }

      // Check if profile picture upload failed
      if (profilePictureUrl.isEmpty) {
        return CustomString.failedToUploadProfilePicture;
      }

      // Create User model object with the provided data
      model.User user = model.User(
        username: username,
        uid: uid,
        email: email,
        friends: [],
        teams: [],
        profilePictureUrl: profilePictureUrl,
        location: location ?? CustomString.emptyString,
        birthDate: birthDate,
        isActive: false,
        searchKey: username.toLowerCase(), // New users start as inactive
        postedTurns: [],
        invitedTurns: [],
        postedCfqs: [],
        invitedCfqs: [],
        favorites: [],
        conversations: [],
      );

      // Save the user data to Firestore under 'users' collection
      await _firestore.collection('users').doc(uid).set(
            user.toJson(),
          );

      res = CustomString.success; // Indicate successful sign-up
    } catch (err) {
      // Handle any errors and return them as a string
      res = err.toString();
    }

    return res;
  }

  // Log in an existing user with email and password
  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = CustomString.someErrorOccurred;

    try {
      // Validate that email and password are provided
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password); // Sign in the user
        res = CustomString.success; // Indicate successful login
      } else {
        res =
            CustomString.pleaseFillInAllRequiredFields; // Handle missing fields
      }
    } catch (err) {
      // Return any errors as a string
      res = err.toString();
    }
    return res;
  }

  // Log out the current user
  Future<String> logOutUser() async {
    String res = CustomString.someErrorOccurred;

    try {
      await _auth.signOut(); // Firebase's method for signing out
      res = CustomString.success; // Indicate successful logout
    } catch (err) {
      // Handle any errors and return them as a string
      res = err.toString();
    }

    return res;
  }
}
