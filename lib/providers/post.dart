// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post with ChangeNotifier {
  String imageUrl;
  String title;
  String description;
  String id;
  String userId;
  int likes;
  int comments;
  Timestamp timestamp;

  Post({
    this.imageUrl,
    this.title,
    this.description,
    this.id,
    this.userId,
    this.likes,
    this.comments,
    this.timestamp,
    caption,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      description: doc['description'],
      likes: doc['likes'],
      comments: doc['comments'],
      timestamp: doc['timestamp'],
      userId: doc['userId'],
      title: doc['title'],
    );
  }
}
