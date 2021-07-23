//@dart=2.9
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> uploadUserProfileImage(
      String url, String userId, File imageFile) async {
    String photoId = userId;
    File image = await compressImage(photoId, imageFile);
    final storageRef = FirebaseStorage.instance.ref();
    StorageUploadTask uploadTask =
        storageRef.child('images/users/userProfile_$photoId').putFile(image);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  static Future<String> uploadPostImage(File imageFile, String photoId) async {
    File image = await compressImage(photoId, imageFile);
    final storageRef = FirebaseStorage.instance.ref();
    StorageUploadTask uploadTask =
        storageRef.child('images/posts/post_$photoId').putFile(image);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  static Future<File> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImage;
  }
}
