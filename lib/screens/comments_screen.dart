//@dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:upost/models/comment.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/services/upost_firestore_service.dart';

class CommentsScreen extends StatefulWidget {
  CommentsScreen({this.post, this.myUserId});
  Post post;
  String myUserId;

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool _isTyping = false;
  TextEditingController _commentController = TextEditingController();

  _buildComment(Comment comment) {
    return FutureBuilder(
      future: UpostFirestoreService.getUserById(comment.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User user = snapshot.data;
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.profileImageUrl.isEmpty
                  ? AssetImage('assets/images/person-placeholder.jpg')
                  : NetworkImage(user.profileImageUrl),
            ),
            title: Text(
              user.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.textComment,
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMd().add_jm().format(
                        comment.timestamp.toDate(),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildMyCommentBar() {
    return IconTheme(
      data: IconThemeData(
        color: _isTyping
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    fillColor: Colors.grey[200],
                    border: InputBorder.none,
                    filled: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {
                      _isTyping = value.length > 0;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            IconButton(
              onPressed: () async {
                if (_isTyping) {
                  UpostFirestoreService.addComment(
                    widget.post,
                    _commentController.text,
                    widget.myUserId,
                  );
                  setState(() {
                    _isTyping = false;
                  });
                  _commentController.clear();
                }
              },
              icon: Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: Firestore.instance
                .collection('comments')
                .document(widget.post.id)
                .collection('postComments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<DocumentSnapshot> commentDocs = snapshot.data.documents;
              return Expanded(
                child: ListView.builder(
                  itemCount: commentDocs.length,
                  itemBuilder: (context, index) {
                    Comment comment = Comment.fromDoc(commentDocs[index]);
                    return _buildComment(comment);
                  },
                ),
              );
            },
          ),
          Divider(
            height: 1,
          ),
          _buildMyCommentBar(),
        ],
      ),
    );
  }
}
