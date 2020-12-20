import 'package:flutter/material.dart';
import 'ExtractedButton.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class AuthIndex extends StatefulWidget {
  static String id = 'welcome_screen';
  @override
  _AuthIndexState createState() => _AuthIndexState();
}

class _AuthIndexState extends State<AuthIndex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('assets/logo.png'),
                    height: 100.0,
                  ),
                ),
//                Text(
//                  'Flash Chat',
//                  style: TextStyle(
//                    fontSize: 45.0,
//                    fontWeight: FontWeight.w900,
//                  ),
//                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            ExtractedButton(
              text: 'Login',
              colour: Colors.purple,
              onclick: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen()));
              },
              child: Container(
                height: 55,
                color: Colors.transparent,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.bold),
                ),
              ),
            )
//            ExtractedButton(
//              text: 'Register',
//              colour: Colors.white,
//              textColour: Colors.purple,
//              onclick: () {
//                Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => RegistrationScreen()));
//              },
//            ),
          ],
        ),
      ),
    );
  }
}
