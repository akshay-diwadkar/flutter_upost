//@dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:upost/models/user.dart';
import 'package:upost/screens/profile_screen.dart';
import 'package:upost/services/upost_firestore_service.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //_searchController will help in clearing the text from the TextFormField
  var _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); //this is the key for the Form
  String searchName;
  Future<QuerySnapshot> _users;
  //_isInit is useful to show a circular progress indicator while searching
  bool _isInit = true;

  Future<void> _submit() async {
    final isValid = _formKey.currentState.validate();
    if (_searchController.text.isEmpty) {
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      //after saved, the below line will close the keyboard
      FocusScope.of(context).unfocus();
      setState(() {
        _isInit = false;
      });
      _users = UpostFirestoreService.searchUsers(searchName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //on tap it will close the keyboard
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Form(
            key: _formKey,
            child: ClipRRect(
              //for circular border
              borderRadius: BorderRadius.circular(40),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 30.0,
                    color: Colors.red,
                  ),
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        //when this clear button will be pressed, it will make the _users
                        //list empty, so the listview builder wont show anything, instead
                        //"no users found" will be displayed
                        //also we clear the typed string from the TextFormField
                        //and set the loading to false
                        _users = null;
                        _searchController.clear();
                      });
                    },
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSaved: (newValue) {
                  searchName = newValue;
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _submit,
          child: Icon(
            Icons.search_rounded,
            size: 30,
          ),
        ),
        body: FutureBuilder(
          future: _users,
          builder: (ctx, snapshot) {
            if (_isInit) {
              return Center(
                child: Text('Search for users'),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                //if loading, then display circular progress indicator
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data.documents.length == 0) {
              return Center(
                //if _users list is empty, display "no users found"
                child: Text('No users found'),
              );
            }
            return ListView.builder(
              //else build a listTile for each user in the _users list
              itemCount: snapshot.data.documents.length,
              itemBuilder: (ctx, i) {
                User user = User.fromDoc(snapshot.data.documents[i]);
                return GestureDetector(
                  onTap: () {
                    //if tapped on the ListTile of a user, it will take it to that user's profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ProfileScreen(
                          userId: user.id,
                          isMe: false,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profileImageUrl.isEmpty
                          ? AssetImage('assets/images/person-placeholder.jpg')
                          : NetworkImage(user.profileImageUrl),
                    ),
                    title: Row(
                      children: [
                        Text(user.username),
                        if (user.isVerified == 'true') Icon(Icons.verified),
                      ],
                    ),
                    subtitle: Text(
                      user.bio,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
