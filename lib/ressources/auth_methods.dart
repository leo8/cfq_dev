import 'dart:typed_data';
import 'package:cfq_dev/ressources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cfq_dev/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetching user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  //Sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    String? location,
    String? bio,
    Uint8List? profilePicture,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        // Register the user
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        // Store profilePicture and get profilePictureUrl
        String profilePictureUrl = '';
        if (profilePicture != null) {
          profilePictureUrl = await StorageMethods()
              .uploadImageToStorage('profilePicture', profilePicture, false);

          // Log the URL to ensure it's not empty
          print('Profile picture URL: $profilePictureUrl');
        }

        // If profilePictureUrl is still empty, something went wrong
        if (profilePictureUrl.isEmpty) {
          return 'Failed to upload profile picture';
        }

        // Create user data with the provided model
        model.User user = model.User(
          username: username,
          uid: userCredential.user!.uid,
          bio: bio ?? "",
          email: email,
          followers: [],
          following: [],
          profilePictureUrl: profilePictureUrl, // Correct assignment
          location: location ?? "",
          isActive: false,
        );

        // Add user to Firestore Database
        await _firestore.collection('users').doc(userCredential.user!.uid).set(
              user.toJson(),
            );

        res = 'success';
      } else {
        res = 'Please fill in all required fields';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  // Log in method
  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = "Please fill in all fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Log out method
  Future<String> logOutUser() async {
    String res = 'Some error occurred';

    try {
      await _auth.signOut(); // Firebase's sign-out method
      res = 'success';
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
