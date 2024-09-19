import 'dart:typed_data';
import 'package:cfq_dev/models/turn.dart';
import 'package:cfq_dev/models/cfq.dart';
import 'package:cfq_dev/ressources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload turn
  Future<String> uploadTurn(
    String turnName,
    String description,
    String mood,
    String uid,
    List organizers,
    String username,
    Uint8List file,
    String profilePictureUrl,
  ) async {
    String res = 'Some error occurred';
    try {
      String turnImageUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      String turnId = const Uuid().v1();

      Turn turn = Turn(
        turnName: turnName,
        description: description,
        mood: mood,
        uid: uid,
        username: username,
        turnId: turnId,
        datePublished: DateTime.now(),
        turnImageUrl: turnImageUrl,
        profilePictureUrl: profilePictureUrl,
        organizers: organizers,
        attending: [],
        notSureAttending: [],
        notAttending: [],
        notAnswered: [],
      );

      _firestore.collection('turns').doc(turnId).set(
            turn.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // upload cfq
  Future<String> uploadCfq(
    String cfqName,
    String description,
    String mood,
    String uid,
    List organizers,
    String username,
    Uint8List file,
    String profilePictureUrl,
  ) async {
    String res = 'Some error occurred';
    try {
      String cfqImageUrl =
          await StorageMethods().uploadImageToStorage('cfqs', file, true);

      String cfqId = const Uuid().v1();

      Cfq cfq = Cfq(
        cfqName: cfqName,
        description: description,
        mood: mood,
        uid: uid,
        username: username,
        cfqId: cfqId,
        datePublished: DateTime.now(),
        cfqImageUrl: cfqImageUrl,
        profilePictureUrl: profilePictureUrl,
        organizers: organizers,
        followers: [], // Initialize followers as an empty list
      );

      _firestore.collection('cfqs').doc(cfqId).set(
            cfq.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}