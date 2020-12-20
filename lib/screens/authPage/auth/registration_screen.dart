import 'package:dailyneedsserver/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'ExtractedButton.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class RegistrationScreen extends StatefulWidget {
  static String id = 'Registraionscreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String conformPassword = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
                height: 20.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                  setState(() {});
                  //Do something with the user input.
                },
                style: TextStyle(color: Colors.black),
                decoration: KtextfieldDecoration.copyWith(
                    hintText: 'Enter email',
                    suffixIcon: checkEmail('$email') == true
                        ? Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.cancel,
                            size: 20,
                            color: Colors.redAccent,
                          )),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                  setState(() {});
                  //Do something with the user input.
                },
                style: TextStyle(color: Colors.black),
                decoration: KtextfieldDecoration.copyWith(
                    hintText: 'Enter password',
                    suffixIcon: checkPassword('$password') == true
                        ? Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.cancel,
                            size: 20,
                            color: Colors.redAccent,
                          )),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  conformPassword = value;
                  setState(() {});
                },
                style: TextStyle(color: Colors.black),
                decoration: KtextfieldDecoration.copyWith(
                    hintText: 'Conform password',
                    suffixIcon: password == conformPassword && password != ''
                        ? Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.cancel,
                            size: 20,
                            color: Colors.redAccent,
                          )),
              ),
              SizedBox(
                height: 12.0,
              ),
              ExtractedButton(
                text: 'Register',
                colour: checkEmail('$email') &&
                        checkPassword('$password') &&
                        password == conformPassword
                    ? Colors.purple
                    : Colors.grey.withOpacity(0.5),
                onclick: () async {
                  if (checkEmail('$email') &&
                      checkPassword('$password') &&
                      password == conformPassword) {
//
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        Map _userDetails = {
                          'name': '$email',
                          'image': '',
                          'email': '$email'
                        };
                        Provider.of<IsInList>(context, listen: false)
                            .addUser(_userDetails);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        setState(() {});
//                      Navigator.pushNamed(context, ChatScreen.id);
                      }
                    } on PlatformException catch (e) {
                      _scaffoldKey.currentState.showSnackBar(
                        new SnackBar(
                          duration: Duration(milliseconds: 3000),
                          backgroundColor: Colors.orange,
                          content: new Text('${e.message}',
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                    setState(() {
                      showSpinner = false;
                    });
//
                  } else {
                    _scaffoldKey.currentState.showSnackBar(
                      new SnackBar(
                        duration: Duration(milliseconds: 1500),
                        backgroundColor: Colors.orange,
                        content: new Text('enter correct details !',
                            style: TextStyle(color: Colors.white)),
                      ),
                    );
                  }
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

bool checkPassword(String password) {
  int a = password.length;
  if (a >= 6) {
    return true;
  }
  return false;
}
