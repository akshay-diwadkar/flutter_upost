//@dart=2.9

import 'package:flutter/material.dart';
import 'package:upost/screens/create_post_screen.dart';
import 'package:upost/screens/feed_screen.dart';
import 'package:upost/screens/profile_screen.dart';
import 'package:upost/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  HomeScreen({this.userId});
  String userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; //for keepting track of the current tab
  PageController _pageController; //needed for pageView

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          FeedScreen(userId: widget.userId),
          SearchScreen(),
          ProfileScreen(userId: widget.userId, isMe: true),
        ],
        onPageChanged: (int value) {
          setState(() {
            _currentTab = value;
          });
        },
      ),
      floatingActionButton: _currentTab == 1
          ? null
          : FloatingActionButton(
              child: Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CreatePostScreen.routeName);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (value) {
          setState(() {
            _currentTab = value;
          });
          _pageController.animateToPage(
            value,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        fixedColor: Colors.red,
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }
}
