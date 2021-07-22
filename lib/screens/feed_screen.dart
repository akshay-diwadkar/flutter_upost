//@dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/screens/post_details_screen.dart';
import 'package:upost/services/upost_firestore_service.dart';
import 'package:upost/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  static const routeName = '/feed';
  String userId;
  FeedScreen({this.userId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool isLoading = false;
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    List<Post> posts =
        await UpostFirestoreService.fetchAndSetPosts(widget.userId);
    setState(() {
      isLoading = false;
      _posts = posts;
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    fetchPosts();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.white,
            ),
            label: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        title: Text(
          'UPost',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => fetchPosts(),
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  Post post = _posts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PostDetailsScreen(
                              post: _posts[index],
                              myUserId: widget.userId,
                            );
                          },
                        ),
                      );
                    },
                    child: FutureBuilder(
                      future: UpostFirestoreService.getUserById(post.userId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink(
                            child: CircularProgressIndicator(),
                          );
                        }
                        User user = snapshot.data;
                        return PostCard(
                          post: _posts[index],
                          user: user,
                          isMe: widget.userId == user.id ? true : false,
                          softWrap: false,
                          myUserId: widget.userId,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
