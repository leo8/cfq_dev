import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    String? bio,
    Uint8List? profilePicture
  }) async {
    String res = 'Some error occurred';
    try {
      if(email.isNotEmpty || password.isNotEmpty || username.isNotEmpty) {
        // Register user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        // Add user to Firestore Database
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'uid': userCredential.user!.uid,
          'bio': bio,
          'email': email,
          'followers': [],
          'following': []
        });
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}