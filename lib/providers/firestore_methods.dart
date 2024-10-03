import 'dart:typed_data';
import 'package:cfq_dev/models/cfq_event_model.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/models/turn_event_model.dart';
import 'package:cfq_dev/providers/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../utils/styles/string.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload a TURN event to Firestore
  Future<String> uploadTurn(
    String turnName,
    String description,
    List<String> moods,
    String uid,
    List<String> organizers,
    String username,
    Uint8List file,
    String profilePictureUrl,
    String where, // General location for the event (e.g., "at home")
    String address, // Precise address for the event
  ) async {
    String res = CustomString.someErrorOccurred;

    try {
      // Upload event image to Firebase Storage and get the download URL
      String turnImageUrl =
          await StorageMethods().uploadImageToStorage('turnImages', file, true);

      // Generate a unique ID for the TURN event
      String turnId = const Uuid().v1();

      // Create a TURN object with the provided data and additional fields
      Turn turn = Turn(
        name: turnName,
        description: description,
        moods: moods,
        uid: uid,
        username: username,
        eventId: turnId,
        datePublished: DateTime.now(),
        eventDateTime: DateTime.now(), // Ideally, use the provided dateTime
        imageUrl: turnImageUrl,
        profilePictureUrl: profilePictureUrl,
        where: where, // General location of the event
        address: address, // Precise address of the event
        organizers: organizers,
        invitees: [], // Initialize invitees list as empty
        attending: [], // Initialize attending list as empty
        notSureAttending: [], // Initialize not sure attending list as empty
        notAttending: [], // Initialize not attending list as empty
        notAnswered: [], // Initialize not answered list as empty
        comments: [], // Initialize comments list as empty
      );

      // Save the TURN object to Firestore under the 'turns' collection
      await _firestore.collection('turns').doc(turnId).set(turn.toJson());

      res = CustomString.success; // Indicate successful upload
    } catch (err) {
      res = err.toString(); // Catch and return any error messages
    }

    return res;
  }

  // Upload a CFQ event to Firestore (unchanged)
  Future<String> uploadCfq(
    String cfqName,
    String description,
    List<String> moods,
    String uid,
    List<String> organizers,
    String username,
    Uint8List file,
    String profilePictureUrl,
    String where, // General location of the CFQ event (e.g., "online")
  ) async {
    String res = CustomString.someErrorOccurred;

    try {
      // Upload CFQ image to Firebase Storage and get the download URL
      String cfqImageUrl =
          await StorageMethods().uploadImageToStorage('cfqs', file, true);

      // Generate a unique ID for the CFQ event
      String cfqId = const Uuid().v1();

      // Create a CFQ object with the provided data
      Cfq cfq = Cfq(
        name: cfqName,
        description: description,
        moods: moods,
        uid: uid,
        username: username,
        eventId: cfqId,
        datePublished: DateTime.now(),
        imageUrl: cfqImageUrl,
        profilePictureUrl: profilePictureUrl,
        where: where, // General location of the CFQ event
        organizers: organizers,
        followers: [], // Initialize followers list as empty
        comments: [], // Initialize comments list as empty
      );

      // Save the CFQ object to Firestore under the 'cfqs' collection
      await _firestore.collection('cfqs').doc(cfqId).set(cfq.toJson());

      res = CustomString.success; // Indicate successful upload
    } catch (err) {
      res = err.toString(); // Catch and return any error messages
    }

    return res;
  }
}
