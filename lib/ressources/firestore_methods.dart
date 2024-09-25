import 'dart:typed_data';
import 'package:cfq_dev/models/turn.dart';
import 'package:cfq_dev/models/cfq.dart';
import 'package:cfq_dev/ressources/storage_methods.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload TURN with 'where' and 'address'
  Future<String> uploadTurn(
    String turnName,
    String description,
    List<String> moods,
    String uid,
    List<String> organizers,
    String username,
    Uint8List file,
    String profilePictureUrl,
    String where,             // New 'where' field (e.g., "at home")
    String address,           // New 'address' field (precise address)
  ) async {
    String res = CustomString.someErrorOccurred;
    try {
      // Upload image to storage
      String turnImageUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      // Generate unique ID for the TURN
      String turnId = const Uuid().v1();

      // Create the TURN object with new 'where' and 'address' fields
      Turn turn = Turn(
        turnName: turnName,
        description: description,
        moods: moods,
        uid: uid,
        username: username,
        turnId: turnId,
        datePublished: DateTime.now(),
        eventDateTime: DateTime.now(),  // Assuming the eventDateTime is DateTime.now(), update accordingly
        turnImageUrl: turnImageUrl,
        profilePictureUrl: profilePictureUrl,
        where: where,                    // Using the new 'where' field
        address: address,                // Using the new 'address' field
        organizers: organizers,
        invitees: [],                    // Initialize invitees as empty
        attending: [],
        notSureAttending: [],
        notAttending: [],
        notAnswered: [],
        comments: []
      );

      // Save TURN data to Firestore
      await _firestore.collection('turns').doc(turnId).set(turn.toJson());
      res = CustomString.success;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Upload CFQ with 'where' field
  Future<String> uploadCfq(
    String cfqName,
    String description,
    List<String> moods,
    String uid,
    List<String> organizers,
    String username,
    Uint8List file,
    String profilePictureUrl,
    String where,             // New 'where' field (e.g., "online")
  ) async {
    String res = CustomString.someErrorOccurred;
    try {
      // Upload image to storage
      String cfqImageUrl =
          await StorageMethods().uploadImageToStorage('cfqs', file, true);

      // Generate unique ID for the CFQ
      String cfqId = const Uuid().v1();

      // Create the CFQ object with new 'where' field
      Cfq cfq = Cfq(
        cfqName: cfqName,
        description: description,
        moods: moods,
        uid: uid,
        username: username,
        cfqId: cfqId,
        datePublished: DateTime.now(),
        cfqImageUrl: cfqImageUrl,
        profilePictureUrl: profilePictureUrl,
        where: where,                    // Using the new 'where' field
        organizers: organizers,
        followers: [],                 // Initialize followers as empty
        comments: [],                 // Initialize comments as empty
      );

      // Save CFQ data to Firestore
      await _firestore.collection('cfqs').doc(cfqId).set(cfq.toJson());
      res = CustomString.success;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
