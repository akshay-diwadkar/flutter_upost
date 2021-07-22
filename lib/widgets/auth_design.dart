// @dart=2.9
import 'package:flutter/material.dart';

class AuthDesign extends StatelessWidget {
  const AuthDesign({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('assets/images/red.png'),
        Positioned(
          top: 100,
          left: 20,
          child: Image.asset('assets/images/light-1.png'),
        ),
        Positioned(
          top: 100,
          left: 90,
          child: Image.asset('assets/images/light-2.png'),
        ),
      ],
    );
  }
}
