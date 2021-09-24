//@dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/screens/edit_profile_screen.dart';
import 'package:upost/screens/post_details_screen.dart';
import 'package:upost/services/upost_firestore_service.dart';
import 'package:upost/widgets/image_preview.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  ProfileScreen({this.userId, this.isMe});
  String userId;
  bool isMe;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Post> userPosts = [];

  String username = '', imageUrl = '', followers = '', following = '', bio = '';
  bool _isInit = true;
  bool isVerified = false;
  bool _isFollowing = false;
  bool _isLoading = false;

  Future<void> _followUnfollowUser() async {
    //this function is only called when the profile we are viewing is not ours
    //so the widget.userId will be passed as arguments to ModalRoute above which will
    //be of the target user.
    setState(() {
      _isLoading = true;
    });
    _isFollowing = await UpostFirestoreService.isFollowing(widget.userId);
    print(_isFollowing.toString() + ' from profile screen');
    if (!_isFollowing) {
      print('calling followUser()');
      await UpostFirestoreService.followUser(widget.userId);
    } else {
      print('calling unFollowUser()');
      await UpostFirestoreService.unfollowUser(widget.userId);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupUserPosts();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    setState(() {});
  }

  void _setupIsFollowing() async {
    bool _isFollowingTarget =
        await UpostFirestoreService.isFollowing(widget.userId);
    _isFollowing = _isFollowingTarget;
  }

  void _setupFollowers() async {
    int userFollowers =
        await UpostFirestoreService.getFollowerCount(widget.userId);
    followers = userFollowers.toString();
  }

  void _setupFollowing() async {
    int userFollowing =
        await UpostFirestoreService.getFollowingCount(widget.userId);
    following = userFollowing.toString();
  }

  Future<void> _setupUserPosts() async {
    List<Post> userP = await UpostFirestoreService.getUserPosts(widget.userId);
    setState(() {
      userPosts = userP;
    });
  }

  _buildProfileInfo(CustomUser user) {
    return Column(
      children: [
        if (_isLoading) LinearProgressIndicator(),
        Padding(
          padding: EdgeInsets.all(30.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ImagePreview.routeName,
                arguments: {
                  'imageUrl': user.profileImageUrl,
                  'userId': user.id,
                },
              );
            },
            child: Hero(
              tag: user.id,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user.profileImageUrl.isEmpty
                    ? AssetImage('assets/images/person-placeholder.jpg')
                    : NetworkImage(user.profileImageUrl),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Text(
                    user.username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // if (isVerified) Icon(Icons.verified)
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
              child: Text(
                user.bio,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'posts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(userPosts.length.toString()),
              ],
            ),
            Column(
              children: [
                Text(
                  'followers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.followers),
              ],
            ),
            Column(
              children: [
                Text(
                  'following',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.following),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        _displayButton(user),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Divider(
            thickness: 2,
          ),
        ),
      ],
    );
  }

  _buildPostTile(Post p) {
    return GridTile(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PostDetailsScreen(
                  post: p,
                  myUserId: p.userId,
                );
              },
            ),
          );
        },
        child: Image.network(
          p.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    List<GridTile> postTiles = [];

    userPosts.forEach((post) {
      postTiles.add(_buildPostTile(post));
    });
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: postTiles,
    );
  }

  Widget _displayButton(CustomUser user) {
    return widget.isMe
        ? RaisedButton.icon(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProfileScreen.routeName, arguments: {
                'userId': user.id,
                'username': user.username,
                'profileImageUrl': user.profileImageUrl,
                'bio': user.bio,
                'followers': user.followers,
                'following': user.following,
                'isVerified': user.isVerified,
              }).then((result) {
                //when we will pop from editProfileScreen we will come to
                //this funtion where we will set the profile image by calling setState
                if (result != null) {
                  setState(() {});
                }
              });
            },
            icon: Icon(Icons.edit),
            label: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        : RaisedButton.icon(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            color: _isFollowing
                ? Colors.grey[500]
                : Theme.of(context).primaryColor,
            onPressed: _followUnfollowUser,
            icon: Icon(Icons.person),
            label: Text(
              _isFollowing ? 'Unfollow' : 'Follow',
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              // Navigator.of(context).pop();
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
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          CustomUser user = CustomUser.fromDoc(snapshot.data);
          return ListView(
            children: [
              _buildProfileInfo(user),
              _buildPostGrid(),
            ],
          );
        },
      ),
    );
  }
}
