//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String textComment;
  String userId;
  Timestamp timestamp;

  Comment({
    this.id,
    this.textComment,
    this.timestamp,
    this.userId,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      textComment: doc['textComment'],
      timestamp: doc['timestamp'],
      userId: doc['userId'],
    );
  }
}
