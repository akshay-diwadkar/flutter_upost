//@dart=2.9
import 'dart:async';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/screens/comments_screen.dart';
import 'package:upost/screens/profile_screen.dart';
import 'package:upost/services/upost_firestore_service.dart';

class PostCard extends StatefulWidget {
  PostCard({
    this.post,
    this.user,
    this.isMe,
    this.softWrap,
    this.myUserId,
  });
  Post post;
  User user;
  bool isMe;
  bool softWrap;
  String myUserId;

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;
  bool likeAnimation = false;
  bool isLoading = false;
  bool isLoadingLikeStatus;

  @override
  void didChangeDependencies() {
    // TODO: implement initState
    likeCount = widget.post.likes;
    _setupLikeStatus();
    super.didChangeDependencies();
  }

  _setupLikeCount() async {
    int likecount = await UpostFirestoreService.getLikeCount(widget.post);
    if (mounted) {
      setState(() {
        likeCount = likecount;
      });
    }
  }

  void _setupLikeStatus() async {
    bool liked =
        await UpostFirestoreService.didLikePost(widget.post, widget.myUserId);
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  void _toggle() async {
    if (isLiked) {
      await UpostFirestoreService.unlikePost(widget.post, widget.myUserId);
      if (mounted) {
        setState(() {
          isLiked = false;
          likeCount = likeCount > 0 ? likeCount - 1 : 0;
        });
      }
    } else {
      await UpostFirestoreService.likePost(widget.post, widget.myUserId);
      if (mounted) {
        setState(() {
          isLiked = true;
          likeCount += 1;
          likeAnimation = true;
        });
      }
      Timer(Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            likeAnimation = false;
          });
        }
      });
    }
  }

  _handleDeletion() async {
    setState(() {
      isLoading = true;
    });
    await UpostFirestoreService.deletePost(widget.post);
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading) LinearProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final _id = widget.post.userId;
                      return ProfileScreen(
                        isMe: widget.isMe,
                        userId: _id,
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    backgroundImage: widget.user.profileImageUrl.isEmpty
                        ? AssetImage('assets/images/person-placeholder.jpg')
                        : NetworkImage(widget.user.profileImageUrl),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    widget.user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            GestureDetector(
              onLongPress: _toggle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.post.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  likeAnimation
                      ? Animator(
                          duration: Duration(milliseconds: 300),
                          tween: Tween(begin: 0.5, end: 1.4),
                          curve: Curves.elasticInOut,
                          builder: (animation) => Transform.scale(
                            scale: animation.value,
                            child: Icon(
                              Icons.favorite,
                              size: 100,
                              color: Colors.pink,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.post.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.post.description,
                softWrap: widget.softWrap,
                overflow:
                    widget.softWrap ? TextOverflow.visible : TextOverflow.fade,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.softWrap && widget.isMe)
                  TextButton.icon(
                    onPressed: _handleDeletion,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    label: Text('Delete post'),
                  ),
                if (!widget.softWrap || !widget.isMe)
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      color: Colors.pink,
                      onPressed: _toggle,
                      icon: isLiked
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_outline),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('${likeCount.toString()} likes'),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CommentsScreen(
                        post: widget.post,
                        myUserId: widget.myUserId,
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.message),
                  SizedBox(
                    width: 10,
                  ),
                  Text('${widget.post.comments} Comments'),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
