//@dart=2.9
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upost/providers/post.dart';
import 'package:upost/services/storage_service.dart';
import 'package:upost/services/upost_firestore_service.dart';

class CreatePostScreen extends StatefulWidget {
  static const routeName = '/create';
  const CreatePostScreen({Key key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController _descriptionController, _titleController;
  bool _isLoading = false;
  String _description, _title;
  File _image;
  _showOptions() {
    return Platform.isIOS ? _showIosOptions() : _showAndroidOptions();
  }

  _showIosOptions() {
    showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return CupertinoActionSheet(
            title: Text('Select a method for picking image'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  _handleImage(ImageSource.camera);
                },
                child: Text('Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  _handleImage(ImageSource.gallery);
                },
                child: Text('Gallery'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
          );
        });
  }

  _showAndroidOptions() {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text('Select a method for picking image'),
            children: [
              SimpleDialogOption(
                child: Text('Camera'),
                onPressed: () {
                  _handleImage(ImageSource.camera);
                },
              ),
              SimpleDialogOption(
                child: Text('Gallery'),
                onPressed: () {
                  _handleImage(ImageSource.gallery);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
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
        _image = _imageFile;
      });
    }
  }

  _submit() async {
    if (!_isLoading && _image != null && _description.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      FocusScope.of(context).unfocus();
      final me = await FirebaseAuth.instance.currentUser();
      String postImageUrl =
          await StorageService.uploadPostImage(me.uid, _image);
      Post _post = Post(
        imageUrl: postImageUrl,
        description: _description,
        likes: 0,
        comments: 0,
        title: _title,
        timestamp: Timestamp.fromDate(DateTime.now()),
        userId: me.uid,
      );
      await UpostFirestoreService.createPost(_post);

      // _descriptionController.clear();
      setState(() {
        _isLoading = false;
        _description = '';
        _title = '';
        _image = null;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Post'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                if (_isLoading) LinearProgressIndicator(),
                GestureDetector(
                  onTap: _showOptions,
                  child: Container(
                    color: Colors.red[300],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: _image != null
                        ? Image(
                            image: FileImage(_image),
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 100,
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 0, 15),
                        prefix: Icon(
                          Icons.text_fields,
                          size: 25,
                        ),
                        labelText: 'Title',
                        hintText: 'Add a title to your post',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _title = value;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 0, 15),
                        prefix: Icon(
                          Icons.notes,
                          size: 25,
                        ),
                        hintText: 'Write a description...',
                        labelText: 'Description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _description = value;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 300,
                  height: 50,
                  child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    onPressed: _submit,
                    icon: Icon(
                      Icons.post_add_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Post it!',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
