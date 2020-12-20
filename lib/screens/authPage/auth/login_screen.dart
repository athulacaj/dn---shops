import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/provider.dart';
import 'package:dailyneedsserver/screens/homeScreen/firebaseMessaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'ExtractedButton.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: RefreshProgressIndicator(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30),
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 110.0,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                style: TextStyle(color: Colors.black),
                decoration:
                    KtextfieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                  //Do something with the user input.
                },
                style: TextStyle(color: Colors.black),
                decoration: KtextfieldDecoration.copyWith(
                    hintText: 'Enter your Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              ExtractedButton(
                text: 'Login',
                colour: Colors.purple,
                onclick: () async {
                  if (checkEmail('$email')) {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final loginUser = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      if (loginUser != null) {
                        print('logined ${loginUser.user.uid}');
                        Map _userDetails = {
                          'name': '$email',
                          'image': '',
                          'email': '$email',
                          'uid': loginUser.user.uid
                        };

//                      Navigator.pushNamed(context, ChatScreen.id);
                        Provider.of<IsInList>(context, listen: false)
                            .addUser(_userDetails);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } on PlatformException catch (e) {
                      _scaffoldKey.currentState.showSnackBar(
                        new SnackBar(
                          duration: Duration(milliseconds: 3000),
                          backgroundColor: Colors.deepPurple,
                          content: new Text('${e.message}',
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      duration: Duration(milliseconds: 1000),
                      backgroundColor: Colors.orange,
                      content: new Text('enter valid email',
                          style: TextStyle(color: Colors.white)),
                    ));
                  }

                  setState(() {
                    showSpinner = false;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

bool checkEmail(String email) {
  List a = email.split('@');
  List b = email.split('.');

  if (a.length == 2) {
    if (b.length == 2) {
      return true;
    }
  }

  return false;
}
