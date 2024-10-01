import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// This class handles file storage operations with Firebase Storage
class StorageMethods {
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // Firebase Authentication instance to access the current user

  // Uploads an image to Firebase Storage and returns the download URL
  Future<String> uploadImageToStorage(
    String
        childName, // The folder name where the file will be stored in Firebase Storage
    Uint8List file, // The image file (in byte format) to be uploaded
    bool
        isPost, // Determines whether the upload is for a post (true) or something else (false)
  ) async {
    // Create a reference to the storage location, including the user's UID as part of the path
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    // If the file is for a post, append a unique ID (UUID) to the file path to prevent overwrites
    if (isPost) {
      String id = const Uuid().v1(); // Generate a unique ID for the post
      ref = ref.child(id); // Update the reference to include the post ID
    }

    // Upload the image file to Firebase Storage
    UploadTask uploadTask = ref.putData(file);

    // Wait for the upload to complete and retrieve the resulting snapshot
    TaskSnapshot snap = await uploadTask;

    // Get the download URL of the uploaded image file from Firebase Storage
    String downloadUrl = await snap.ref.getDownloadURL();

    // Return the URL, which can be used to display or reference the image later
    return downloadUrl;
  }
}
