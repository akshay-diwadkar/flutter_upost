//@dart=2.9
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upost/services/storage_service.dart';
import 'package:upost/widgets/image_preview.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({Key key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final key = GlobalKey<FormState>();
  String username;
  String userId;
  String imageUrl;
  String followers;
  String following;
  String bio;
  String isVerified;
  bool _isLoading = false;
  bool _isInit = true;
  var _initValues = {
    'userId': '',
    'username': '',
    'imageUrl': '',
    'followers': '',
    'following': '',
    'bio': '',
    'isVerified': '',
  };
  File _profileImage;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, String>;
      username = routeArgs['username'];
      userId = routeArgs['userId'];
      imageUrl = routeArgs['profileImageUrl'];
      followers = routeArgs['followers'];
      following = routeArgs['following'];
      bio = routeArgs['bio'];
      isVerified = routeArgs['isVerified'];

      _initValues = {
        'userId': userId,
        'username': username,
        'imageUrl': imageUrl,
        'followers': followers,
        'following': following,
        'bio': bio,
        'isVerified': isVerified,
      };
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  _showPopup() {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text(
              'Select a method for picking image',
              style: TextStyle(fontSize: 18),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  'Camera',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  _handleImage(ImageSource.camera);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  _handleImage(ImageSource.gallery);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  _cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  _handleImage(ImageSource source) async {
    Navigator.of(context).pop();
    File _imageFile = await ImagePicker.pickImage(source: source);
    if (_imageFile != null) {
      _imageFile = await _cropImage(_imageFile);
      setState(() {
        _profileImage = _imageFile;
      });
    }
  }

  _displayProfileImage() {
    //No new profile image
    if (_profileImage == null) {
      //Display place holder
      if (imageUrl.isEmpty) {
        return AssetImage('assets/images/person-placeholder.jpg');
      } else {
        //display existing image
        return NetworkImage(imageUrl);
      }
    } else {
      //There is a profile image
      return FileImage(_profileImage);
    }
  }

  Future<void> _submit() async {
    final _isValid = key.currentState.validate();
    if (_isValid) {
      key.currentState.save();
      //after saving the form, set loading to true
      setState(() {
        _isLoading = true;
      });
      try {
        if (_profileImage != null) {
          //if there is profile image is selected, we upload the profile picture
          imageUrl = await StorageService.uploadUserProfileImage(
              imageUrl, userId, _profileImage);
        }
        await Firestore.instance
            .collection('users')
            .document(userId)
            .updateData(
          {
            'username': username.trim(),
            'bio': bio.trim(),
            'profileImageUrl': imageUrl,
          },
        );
      } catch (error) {
        throw error;
      }
    }
    //after all the uploading and updating has finished, set loading to false
    //and pop the screen back to the profile screen using an id, so that the result
    //recieved in the "then()" function of the profile screen after the pushnamed is not null
    // if its not null it means something was passed to it, and the setState in "then()"
    //triggers rebuild using the new data which is present on the realtime database
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            if (_isLoading) LinearProgressIndicator(),
            Form(
              key: key,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 0, 30, 30),
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                ImagePreview.routeName,
                                arguments: {
                                  'imageUrl': imageUrl,
                                  'userId': userId,
                                },
                              );
                            },
                            child: Hero(
                              tag: userId,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _displayProfileImage(),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showPopup,
                            icon: Icon(Icons.edit),
                            label: Text(
                              'Change Profile Image',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            key: ValueKey('username'),
                            initialValue: _initValues['username'],
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: Theme.of(context).accentColor,
                              ),
                              labelText: 'Username',
                            ),
                            validator: (value) {
                              if (value.trim().isEmpty ||
                                  value.trim().length < 7) {
                                return 'Username must be at least 7 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              username = value;
                            },
                          ),
                          TextFormField(
                            key: ValueKey('bio'),
                            initialValue: _initValues['bio'],
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.book,
                                color: Theme.of(context).accentColor,
                              ),
                              labelText: 'Bio',
                            ),
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'bio must not be empty';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              bio = value;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 100,
                            child: RaisedButton.icon(
                              onPressed: _isLoading ? () {} : _submit,
                              icon: Icon(Icons.save),
                              label: Text('Save Profile'),
                              color: _isLoading
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
