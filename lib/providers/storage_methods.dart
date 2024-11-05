import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// This class handles file storage operations with Firebase Storage
class StorageMethods {
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance

  // Uploads an image to Firebase Storage and returns the download URL
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    String uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}';
    Reference ref = _storage.ref().child(childName).child(uniqueFileName);

    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
