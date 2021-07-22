//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';

class UpostFirestoreService {
//Searching for users
  static Future<QuerySnapshot> searchUsers(String searchName) {
    Future<QuerySnapshot> _searchedUsers = Firestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchName)
        .getDocuments();
    return _searchedUsers;
  }

  static Future<int> getFollowerCount(String userId) async {
    QuerySnapshot followerSnapshot = await Firestore.instance
        .collection('followers')
        .document(userId)
        .collection('userFollowers')
        .getDocuments();
    return followerSnapshot.documents.length;
  }

  static Future<int> getFollowingCount(String userId) async {
    QuerySnapshot followingSnapshot = await Firestore.instance
        .collection('following')
        .document(userId)
        .collection('userFollowing')
        .getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<void> followUser(String targetUserId) async {
    final me = await FirebaseAuth.instance.currentUser();
    final _followers = await getFollowerCount(targetUserId);
    final _following = await getFollowingCount(me.uid);
    await Firestore.instance
        .collection('followers')
        .document(targetUserId)
        .collection('userFollowers')
        .document(me.uid)
        .setData({});

    await Firestore.instance
        .collection('following')
        .document(me.uid)
        .collection('userFollowing')
        .document(targetUserId)
        .setData({});

    await Firestore.instance
        .collection('users')
        .document(targetUserId)
        .updateData({
      'followers': (_followers + 1).toString(),
    });

    await Firestore.instance.collection('users').document(me.uid).updateData({
      'following': (_following + 1).toString(),
    });
  }

  static Future<void> unfollowUser(String targetUserId) async {
    final me = await FirebaseAuth.instance.currentUser();
    final _followers = await getFollowerCount(targetUserId);
    final _following = await getFollowingCount(me.uid);
    await Firestore.instance
        .collection('followers')
        .document(targetUserId)
        .collection('userFollowers')
        .document(me.uid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    await Firestore.instance
        .collection('following')
        .document(me.uid)
        .collection('userFollowing')
        .document(targetUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    await Firestore.instance
        .collection('users')
        .document(targetUserId)
        .updateData({
      'followers': (_followers - 1).toString(),
    });

    await Firestore.instance.collection('users').document(me.uid).updateData({
      'following': (_following - 1).toString(),
    });
  }

  static Future<bool> isFollowing(String targetUserId) async {
    final me = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot _followingDoc = await Firestore.instance
        .collection('following')
        .document(me.uid)
        .collection('userFollowing')
        .document(targetUserId)
        .get();
    return _followingDoc.exists;
  }

  static Future<void> createPost(Post _post) async {
    String id;
    DocumentReference doc = await Firestore.instance
        .collection('posts')
        .document(_post.userId)
        .collection('usersPosts')
        .add({
      'imageUrl': _post.imageUrl,
      'description': _post.description,
      'title': _post.title,
      'likes': _post.likes,
      'userId': _post.userId,
      'comments': _post.comments,
      'timestamp': _post.timestamp,
    });
    id = doc.documentID;
    await Firestore.instance.collection('feed').document(id).setData({
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
    await Firestore.instance
        .collection('posts')
        .document(post.userId)
        .collection('usersPosts')
        .document(post.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<List<Post>> fetchAndSetPosts(String userId) async {
    QuerySnapshot _feedSnapshot = await Firestore.instance
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> _posts =
        _feedSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return _posts;
  }

  static Future<User> getUserById(String userId) async {
    DocumentSnapshot userDoc =
        await Firestore.instance.collection('users').document(userId).get();
    if (userDoc.exists) {
      return User.fromDoc(userDoc);
    }
    return User();
  }

  static Future<void> likePost(Post post, String userWhoLiked) async {
    int likeCount;
    DocumentReference docRef = await Firestore.instance
        .collection('posts')
        .document(post.userId)
        .collection('usersPosts')
        .document(post.id);

    docRef.get().then((doc) async {
      likeCount = doc.data['likes'];
      await Firestore.instance
          .collection('posts')
          .document(post.userId)
          .collection('usersPosts')
          .document(post.id)
          .updateData({
        'likes': (likeCount + 1),
      });
      await Firestore.instance.collection('feed').document(post.id).updateData({
        'likes': (likeCount + 1),
      });
      await Firestore.instance
          .collection('likes')
          .document(post.id)
          .collection('postLikes')
          .document(userWhoLiked)
          .setData({});
    });
  }

  static Future<void> unlikePost(Post post, String userWhoUnliked) async {
    int likeCount;
    DocumentReference docRef = await Firestore.instance
        .collection('posts')
        .document(post.userId)
        .collection('usersPosts')
        .document(post.id);

    docRef.get().then((doc) async {
      likeCount = doc.data['likes'];
      await Firestore.instance
          .collection('posts')
          .document(post.userId)
          .collection('usersPosts')
          .document(post.id)
          .updateData({
        'likes': (likeCount - 1),
      });
      await Firestore.instance.collection('feed').document(post.id).updateData({
        'likes': (likeCount - 1),
      });
      await Firestore.instance
          .collection('likes')
          .document(post.id)
          .collection('postLikes')
          .document(userWhoUnliked)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  static Future<bool> didLikePost(Post post, String userId) async {
    DocumentSnapshot userDoc = await Firestore.instance
        .collection('likes')
        .document(post.id)
        .collection('postLikes')
        .document(userId)
        .get();
    return userDoc.exists;
  }

  static Future<int> getLikeCount(Post post) async {
    int likeCount;
    DocumentReference docRef = Firestore.instance
        .collection('posts')
        .document(post.userId)
        .collection('usersPosts')
        .document(post.id);

    docRef.get().then((doc) async {
      likeCount = doc.data['likes'];
    });
    return likeCount;
  }

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await Firestore.instance
        .collection('posts')
        .document(userId)
        .collection('usersPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> userPosts =
        userPostsSnapshot.documents.map((post) => Post.fromDoc(post)).toList();
    return userPosts;
  }

  static Future<DocumentSnapshot> getUserDocument(String userId) async {
    DocumentSnapshot documentSnapshot =
        await Firestore.instance.collection('users').document(userId).get();
    return documentSnapshot;
  }

  static Future<void> addComment(
      Post post, String comment, String userId) async {
    DocumentReference docRef = await Firestore.instance
        .collection('comments')
        .document(post.id)
        .collection('postComments')
        .add({
      'textComment': comment,
      'userId': userId,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });

    int commentCount = await getCommentCount(post, comment, userId);

    Firestore.instance
        .collection('posts')
        .document(post.userId)
        .collection('usersPosts')
        .document(post.id)
        .updateData({
      'comments': (commentCount),
    }).then((value) {
      Firestore.instance.collection('feed').document(post.id).updateData({
        'comments': commentCount,
      });
    });
  }

  static Future<int> getCommentCount(
      Post post, String comment, String userId) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('comments')
        .document(post.id)
        .collection('postComments')
        .getDocuments();
    print('number of documents = ${querySnapshot.documents.length}');
    return querySnapshot.documents.length;
  }
}
