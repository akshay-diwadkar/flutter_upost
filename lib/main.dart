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
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text(snapshot.data.toString());
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
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
          value: CustomUser(),
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
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              return HomeScreen(userId: userSnapshot.data.uid);
            }
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
