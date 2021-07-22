//@dart=2.9
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  static const routeName = '/image-preview';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final imageUrl = args['imageUrl'];
    final userId = args['userId'];
    return Hero(
      tag: userId,
      child: Container(
        child: imageUrl.isEmpty
            ? Image.asset(
                'assets/images/person-placeholder.jpg',
                fit: BoxFit.contain,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
