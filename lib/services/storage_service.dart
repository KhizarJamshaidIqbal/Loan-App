// ignore_for_file: avoid_print

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String path) async {
    try {
      // Create the file metadata
      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path});

      // Upload file with retry logic
      final uploadTask = await _retryUpload(file, path, metadata);

      if (uploadTask == null) return null;

      // Get download URL
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<UploadTask?> _retryUpload(
    File file,
    String path,
    SettableMetadata metadata,
  ) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        final ref = _storage.ref().child(path);
        return ref.putFile(file, metadata);
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) {
          print('Failed to upload after $maxAttempts attempts');
          return null;
        }
        await Future.delayed(
            Duration(seconds: attempts)); // Exponential backoff
      }
    }
    return null;
  }
}
