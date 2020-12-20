import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/provider.dart';
import 'package:dailyneedsserver/screens/errorScreen.dart';
import 'package:dailyneedsserver/screens/homeScreen/firebaseMessaging.dart';
import 'package:dailyneedsserver/screens/homeScreen/homeScreen.dart';
import 'package:dailyneedsserver/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'auth/ExtractedButton.dart';
import 'auth/constants.dart';

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

bool _showSpinner = false;
String phone = '';
String name = '';
String email = '';

class _NewUserState extends State<NewUser> {
  String token;
  @override
  void initState() {
    getToken();
    super.initState();
  }

  getToken() async {
    FireBaseMessagingClass fireBaseMessagingClass = FireBaseMessagingClass();
    fireBaseMessagingClass.FirebaseConfigure();
    token = await fireBaseMessagingClass.getFirebaseToken();
    print(token);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String uid =
        Provider.of<IsInList>(context, listen: false).userDetails['uid'];
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: RefreshProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(theme.primaryColorDark),
      ),
      child: Scaffold(
        // key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Padding(
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
                textAlign: TextAlign.center,
                obscureText: false,
                onChanged: (value) {
                  name = value;
                  setState(() {});
                  //Do something with the user input.
                },
                style: TextStyle(color: Colors.black),
                decoration: KtextfieldDecoration.copyWith(
                    hintText: 'Enter name',
                    suffixIcon: name.length > 2
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
                obscureText: false,
                onChanged: (value) {
                  email = value;
                  setState(() {});
                },
                style: TextStyle(color: Colors.black),
                decoration: KtextfieldDecoration.copyWith(
                    hintText: 'Enter phone number',
                    suffixIcon: email.length >= 10
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
                colour: email.length >= 10 && name.length > 2
                    ? Colors.green
                    : Colors.grey.withOpacity(0.5),
                onclick: () async {
                  _showSpinner = true;
                  setState(() {});
                  if (email.length >= 10 && name.length > 2) {
                    await FirebaseFirestore.instance
                        .collection('admin/admin/shops')
                        .doc(uid)
                        .set({
                      'phone': int.parse(email),
                      'name': name,
                      'uid': uid,
                      'isAvailable': false,
                      'token': token
                    });
                    Provider.of<IsInList>(context, listen: false).addUser({
                      'phone': int.parse(email),
                      'name': name,
                      'uid': uid,
                    });
                  }

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => ErrorScreen()));

                  // setState(() {});
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

bool checkPhone(String phone) {
  if (phone.length == 10) {
    return true;
  }
  return false;
}

bool checkEmail(String email) {
  List a = email.split('@');

  if (a.length == 2) {
    if (email.length > 10) {
      if (email.endsWith('.com')) {
        return true;
      }
    }
  }

  return false;
}
