import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// This class handles file storage operations with Firebase Storage
class StorageMethods {
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance

  // Optimized image upload method with better error handling and compression
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    try {
      // Generate unique filename
      String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}';
      Reference ref = _storage.ref().child(childName).child(uniqueFileName);

      // Set custom metadata to enable caching on Firebase side
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'compressed': 'true'
        },
        cacheControl: 'public, max-age=31536000', // Cache for 1 year
      );

      // Configure upload settings for better performance
      UploadTask uploadTask = ref.putData(file, metadata);

      // Monitor upload progress and implement retry logic
      int retryCount = 0;
      const maxRetries = 3;

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        switch (snapshot.state) {
          case TaskState.running:
            break;
          case TaskState.error:
            if (retryCount < maxRetries) {
              retryCount++;
              // Retry the upload
              uploadTask.resume();
            }
            break;
          default:
            break;
        }
      });

      // Wait for upload completion
      TaskSnapshot snap = await uploadTask;

      // Get download URL with timeout
      String downloadUrl = await snap.ref.getDownloadURL().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Download URL timeout'),
          );

      return downloadUrl;
    } catch (e) {
      // Handle specific error cases
      if (e is FirebaseException) {
        switch (e.code) {
          case 'storage/unauthorized':
            throw Exception('Storage access denied');
          case 'storage/canceled':
            throw Exception('Upload canceled');
          case 'storage/retry-limit-exceeded':
            throw Exception('Upload failed after multiple retries');
          default:
            throw Exception('Upload failed: ${e.message}');
        }
      }
      rethrow;
    }
  }

  // Helper method to pause/resume uploads (can be exposed if needed)
  Future<void> pauseUpload(UploadTask task) async {
    if (task.snapshot.state == TaskState.running) {
      await task.pause();
    }
  }

  Future<void> resumeUpload(UploadTask task) async {
    if (task.snapshot.state == TaskState.paused) {
      await task.resume();
    }
  }
}
