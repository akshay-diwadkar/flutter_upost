//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/services/upost_firestore_service.dart';
import 'package:upost/widgets/post_card.dart';

class PostDetailsScreen extends StatefulWidget {
  static const routeName = '/post-details';
  PostDetailsScreen({this.post, this.myUserId});
  Post post;
  String myUserId;
  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  Post newPost;
  CustomUser _user;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    CustomUser user =
        await UpostFirestoreService.getUserById(widget.post.userId);
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.userId)
        .collection('usersPosts')
        .doc(widget.post.id)
        .get();
    newPost = Post.fromDoc(documentSnapshot);
    setState(() {
      _user = user;
      isLoading = false;
    });
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UPost'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(
                    post: newPost,
                    user: _user,
                    isMe: widget.myUserId == _user.id ? true : false,
                    softWrap: true,
                    myUserId: widget.myUserId,
                  ),
                ],
              ),
            ),
    );
  }
}
