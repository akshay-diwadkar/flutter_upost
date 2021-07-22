//@dart=2.9
import 'package:animator/animator.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String username,
    bool isLoginScreen,
    BuildContext ctx,
  ) submitFn;
  bool isLoading;
  AuthForm(this.submitFn, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLoginScreen = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _isLoginScreen,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _isLoginScreen ? 'Welcome back' : 'Greetings!',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: TextFormField(
                    key: ValueKey('e-mail'),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid e-mail address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                      border: InputBorder.none,
                      labelText: 'E-Mail',
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                ),
                SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                      border: InputBorder.none,
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                ),
                SizedBox(height: 5),
                if (!_isLoginScreen)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: TextFormField(
                      key: ValueKey('username'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blueGrey[50],
                        border: InputBorder.none,
                        labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.person_pin,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onSaved: (value) {
                        _userName = value;
                      },
                    ),
                  ),
                SizedBox(height: 14),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      _isLoginScreen ? 'Login' : 'Signup',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _trySubmit,
                  ),
                SizedBox(height: 8),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    _isLoginScreen
                        ? 'Create a new account'
                        : 'Go back to login',
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoginScreen = !_isLoginScreen;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
