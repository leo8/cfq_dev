import 'dart:typed_data';
import 'package:cfq_dev/ressources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      String? location,
      String? bio,
      Uint8List? profilePicture}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty) {
        // Register user
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        // Store profilePicture and get profilePictureUrl
        String profilePictureUrl = '';
        if (profilePicture != null) {
          String profilePictureUrl = await StorageMethods()
              .uploadImageToStorage('profilePicture', profilePicture, false);
        }

        // Create user with data model

        model.User user = model.User(
          username: username,
          uid: userCredential.user!.uid,
          bio: (bio != null) ? bio : "",
          email: email,
          followers: [],
          following: [],
          profilePictureUrl: profilePictureUrl,
          location: (location != null) ? location : "",
          isActive: false,
        );

        // Add user to Firestore Database
        await _firestore.collection('users').doc(userCredential.user!.uid).set(
              user.toJson(),
            );
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<String> logInUser(
      {required String email, required String password}) async {
    String res = 'Some error occurred';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = "Certains champs sont vides";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
