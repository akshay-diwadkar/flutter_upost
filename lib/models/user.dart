//@dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CustomUser with ChangeNotifier {
  String id;
  String username;
  String email;
  String followers;
  String following;
  String bio;
  String profileImageUrl;
  String isVerified;

  CustomUser({
    this.id,
    this.username,
    this.email,
    this.followers,
    this.following,
    this.bio,
    this.profileImageUrl,
    this.isVerified = 'false',
  });

  factory CustomUser.fromDoc(DocumentSnapshot doc) {
    return CustomUser(
      id: doc.id,
      username: doc['username'],
      email: doc['email'],
      bio: doc['bio'],
      followers: doc['followers'],
      following: doc['following'],
      profileImageUrl: doc['profileImageUrl'],
      isVerified: doc['isVerified'],
    );
  }

  void verifyUser() {
    isVerified = 'true';
    notifyListeners();
  }
}
