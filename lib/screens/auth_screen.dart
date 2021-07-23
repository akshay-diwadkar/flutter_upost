//@dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //for restrict orientation to portrait on login screen
import 'package:upost/widgets/auth_design.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upost/widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _auth = FirebaseAuth.instance;
  var _isLoading = false;

  //For restricting orientation to portrait mode in this screen
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // For removing restrictions while leaving this screen
  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    bool isLoginScreen,
    BuildContext ctx,
  ) async {
    AuthResult authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLoginScreen) {
        // log user in
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        //create new user
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .setData({
          'username': username,
          'username_lowercase': username.toLowerCase(),
          'email': email,
          'followers': '0',
          'following': '0',
          'bio': 'Write something here...',
          'profileImageUrl': '',
          'isVerified': 'false',
        });
      }
    } on PlatformException catch (error) {
      var message = 'An error occured, please try again later.';
      if (error.message != null) {
        message = error.message;
      }
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.yellow,
                  Colors.amber,
                  Colors.redAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -110,
            left: 0,
            child: Container(
              height: MediaQuery.of(context).size.width + 100,
              width: MediaQuery.of(context).size.width,
              child: AuthDesign(),
            ),
          ),
          Container(
            child: Column(
              children: [
                Spacer(),
                Expanded(
                  child: Container(
                    height: 200,
                    width: 200,
                    child: Image.asset('assets/images/UPost.png'),
                  ),
                ),
                AuthForm(_submitAuthForm, _isLoading),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
