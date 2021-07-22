// @dart=2.9
//the above line overrides null safety

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upost/models/user.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/screens/auth_screen.dart';
import 'package:upost/screens/create_post_screen.dart';
import 'package:upost/screens/edit_profile_screen.dart';
import 'package:upost/screens/feed_screen.dart';
import 'package:upost/screens/home_screen.dart';
import 'package:upost/screens/post_details_screen.dart';
import 'package:upost/screens/profile_screen.dart';
import 'package:upost/screens/search_screen.dart';
import 'package:upost/widgets/image_preview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //declaring change notifiers using value constructor
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Post(),
        ),
        ChangeNotifierProvider.value(
          value: User(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, //remove the debug banner
        title: 'UPost',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.redAccent,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              return HomeScreen(userId: userSnapshot.data.uid);
            }
            print(userSnapshot);
            return AuthScreen();
          },
        ),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          CreatePostScreen.routeName: (ctx) => CreatePostScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          SearchScreen.routeName: (ctx) => SearchScreen(),
          FeedScreen.routeName: (ctx) => FeedScreen(),
          EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
          ImagePreview.routeName: (ctx) => ImagePreview(),
          PostDetailsScreen.routeName: (ctx) => PostDetailsScreen(),
        },
      ),
    );
  }
}
