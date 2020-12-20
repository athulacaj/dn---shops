import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authPage/phoneAuth/login.dart';
import 'authPage/registerForm.dart';
import 'errorScreen.dart';
import 'homeScreen/homeScreen.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
List homeAdsFromSplash = [];
List meatAdsFromSplash = [];
bool _showSpinner = true;
final FirebaseAuth auth = FirebaseAuth.instance;

class SplashScreenWindow extends StatefulWidget {
  static String id = 'Splash_Screen';

  @override
  _SplashScreenWindowState createState() => _SplashScreenWindowState();
}

class _SplashScreenWindowState extends State<SplashScreenWindow> {
  @override
  void initState() {
    initFunctions();
    super.initState();
  }

  initFunctions() {
    firebaseFunctions();
  }

  Future<bool> getUserDataAndNotifications() async {
    final localData = await SharedPreferences.getInstance();
    String userData = localData.getString('userNew') ?? '';
    print('splash scren: $userData');
    if (userData == "null" || userData == '') {
      return false;
    } else {
      Map user = jsonDecode(userData);
      Provider.of<IsInList>(context, listen: false).addUser(user);
      return true;
    }
  }

  firebaseFunctions() async {
    await Firebase.initializeApp();
    bool _isLogined = await getUserDataAndNotifications();

    await Future.delayed(Duration(seconds: 1));
    if (_isLogined == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => PhoneLoginScreen()));
    } else {
      try {
        Map userData =
            Provider.of<IsInList>(context, listen: false).userDetails;
        print('uid ${userData['uid']}');
        bool isAuthorized = false;
        print('uid ${userData['uid']}');

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {}
    }

    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => HomeScreen(
    //               meatAds: meatAdsFromSplash,
    //               homeAds: homeAdsFromSplash,
    //             )));
    _showSpinner = false;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: RefreshProgressIndicator(),
      inAsyncCall: _showSpinner,
      child: Scaffold(
        body: Center(
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
