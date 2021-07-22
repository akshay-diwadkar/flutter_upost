//@dart=2.9
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  String id;
  String username;
  String email;
  String followers;
  String following;
  String bio;
  String profileImageUrl;
  String isVerified;

  User({
    this.id,
    this.username,
    this.email,
    this.followers,
    this.following,
    this.bio,
    this.profileImageUrl,
    this.isVerified = 'false',
  });

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
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
