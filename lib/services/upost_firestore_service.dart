//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';

class UpostFirestoreService {
//Searching for users
  static Future<QuerySnapshot> searchUsers(String searchName) {
    Future<QuerySnapshot> _searchedUsers = FirebaseFirestore.instance
        .collection('users')
        .where(
          'username_lowercase',
          isGreaterThanOrEqualTo: searchName.toLowerCase(),
        )
        .get();
    return _searchedUsers;
  }

  static Future<int> getFollowerCount(String userId) async {
    QuerySnapshot followerSnapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(userId)
        .collection('userFollowers')
        .get();
    return followerSnapshot.docs.length;
  }

  static Future<int> getFollowingCount(String userId) async {
    QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
        .collection('following')
        .doc(userId)
        .collection('userFollowing')
        .get();
    return followingSnapshot.docs.length;
  }

  static Future<void> followUser(String targetUserId) async {
    final me = await FirebaseAuth.instance.currentUser;
    final _followers = await getFollowerCount(targetUserId);
    final _following = await getFollowingCount(me.uid);
    await FirebaseFirestore.instance
        .collection('followers')
        .doc(targetUserId)
        .collection('userFollowers')
        .doc(me.uid)
        .set({});

    await FirebaseFirestore.instance
        .collection('following')
        .doc(me.uid)
        .collection('userFollowing')
        .doc(targetUserId)
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId)
        .update({
      'followers': (_followers + 1).toString(),
    });

    await FirebaseFirestore.instance.collection('users').doc(me.uid).update({
      'following': (_following + 1).toString(),
    });
  }

  static Future<void> unfollowUser(String targetUserId) async {
    final me = await FirebaseAuth.instance.currentUser;
    final _followers = await getFollowerCount(targetUserId);
    final _following = await getFollowingCount(me.uid);
    await FirebaseFirestore.instance
        .collection('followers')
        .doc(targetUserId)
        .collection('userFollowers')
        .doc(me.uid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    await FirebaseFirestore.instance
        .collection('following')
        .doc(me.uid)
        .collection('userFollowing')
        .doc(targetUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId)
        .update({
      'followers': (_followers - 1).toString(),
    });

    await FirebaseFirestore.instance.collection('users').doc(me.uid).update({
      'following': (_following - 1).toString(),
    });
  }

  static Future<bool> isFollowing(String targetUserId) async {
    final me = await FirebaseAuth.instance.currentUser;
    DocumentSnapshot _followingDoc = await FirebaseFirestore.instance
        .collection('following')
        .doc(me.uid)
        .collection('userFollowing')
        .doc(targetUserId)
        .get();
    return _followingDoc.exists;
  }

  static Future<void> createPost(Post _post) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(_post.userId)
        .collection('usersPosts')
        .doc(_post.id)
        .set({
      'imageUrl': _post.imageUrl,
      'description': _post.description,
      'title': _post.title,
      'likes': _post.likes,
      'userId': _post.userId,
      'comments': _post.comments,
      'timestamp': _post.timestamp,
    });
    await FirebaseFirestore.instance.collection('feed').doc(_post.id).set({
      'imageUrl': _post.imageUrl,
      'description': _post.description,
      'title': _post.title,
      'likes': _post.likes,
      'userId': _post.userId,
      'comments': _post.comments,
      'timestamp': _post.timestamp,
    });
  }

  static Future<void> deletePost(Post post) async {
    await FirebaseStorage.instance.refFromURL(post.imageUrl).delete();
    await FirebaseFirestore.instance
        .collection('likes')
        .doc(post.id)
        .collection('postLikes')
        .doc(post.userId)
        .get()
        .then((doc) async {
      if (doc.exists) {
        doc.reference.delete();
        await FirebaseFirestore.instance
            .collection('likes')
            .doc(post.id)
            .get()
            .then((d) {
          if (d.exists) {
            d.reference.delete();
          }
        });
      }
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(post.id)
        .collection('postComments')
        .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('usersPosts')
        .doc(post.id)
        .get()
        .then((doc) async {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await FirebaseFirestore.instance
        .collection('feed')
        .doc(post.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<List<Post>> fetchAndSetPosts(String userId) async {
    QuerySnapshot _feedSnapshot = await FirebaseFirestore.instance
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> _posts =
        _feedSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return _posts;
  }

  static Future<CustomUser> getUserById(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return CustomUser.fromDoc(userDoc);
    }
    return CustomUser();
  }

  static Future<void> likePost(Post post, String userWhoLiked) async {
    int likeCount;
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('usersPosts')
        .doc(post.id);

    docRef.get().then((doc) async {
      Map<String, dynamic> docMap = doc.data();
      likeCount = docMap['likes'];
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.userId)
          .collection('usersPosts')
          .doc(post.id)
          .update({
        'likes': (likeCount + 1),
      });
      await FirebaseFirestore.instance.collection('feed').doc(post.id).update({
        'likes': (likeCount + 1),
      });
      await FirebaseFirestore.instance
          .collection('likes')
          .doc(post.id)
          .collection('postLikes')
          .doc(userWhoLiked)
          .set({});
    });
  }

  static Future<void> unlikePost(Post post, String userWhoUnliked) async {
    int likeCount;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('usersPosts')
        .doc(post.id);

    docRef.get().then((doc) async {
      Map<String, dynamic> docMap = doc.data();
      likeCount = docMap['likes'];
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.userId)
          .collection('usersPosts')
          .doc(post.id)
          .update({
        'likes': (likeCount - 1),
      });
      await FirebaseFirestore.instance.collection('feed').doc(post.id).update({
        'likes': (likeCount - 1),
      });
      await FirebaseFirestore.instance
          .collection('likes')
          .doc(post.id)
          .collection('postLikes')
          .doc(userWhoUnliked)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  static Future<bool> didLikePost(Post post, String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('likes')
        .doc(post.id)
        .collection('postLikes')
        .doc(userId)
        .get();
    return userDoc.exists;
  }

  static Future<int> getLikeCount(Post post) async {
    int likeCount;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('usersPosts')
        .doc(post.id);

    docRef.get().then((doc) async {
      Map<String, dynamic> docMap = doc.data();
      likeCount = docMap['likes'];
    });
    return likeCount;
  }

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(userId)
        .collection('usersPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> userPosts =
        userPostsSnapshot.docs.map((post) => Post.fromDoc(post)).toList();
    return userPosts;
  }

  static Future<DocumentSnapshot> getUserDocument(String userId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return documentSnapshot;
  }

  static Future<void> addComment(
      Post post, String comment, String userId) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('comments')
        .doc(post.id)
        .collection('postComments')
        .add({
      'textComment': comment,
      'userId': userId,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });

    int commentCount = await getCommentCount(post, comment, userId);

    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('usersPosts')
        .doc(post.id)
        .update({
      'comments': (commentCount),
    }).then((value) {
      FirebaseFirestore.instance.collection('feed').doc(post.id).update({
        'comments': commentCount,
      });
    });
  }

  static Future<int> getCommentCount(
      Post post, String comment, String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(post.id)
        .collection('postComments')
        .get();
    print('number of documents = ${querySnapshot.docs.length}');
    return querySnapshot.docs.length;
  }
}
