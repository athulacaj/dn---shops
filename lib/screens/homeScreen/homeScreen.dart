import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/Extracted/extractedContainer.dart';
import 'package:dailyneedsserver/provider.dart';
import 'package:dailyneedsserver/screens/calculation/calculationScreen.dart';
import 'package:dailyneedsserver/screens/orders/AllOders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'firebaseMessaging.dart';

Firestore _firestrore = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
var uid;
String firebaseUid;
bool _showSpinner = false;
bool _isAdmin = false;

class HomeScreen extends StatefulWidget {
  static String id = 'Home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Map userData = Provider.of<IsInList>(context, listen: false).userDetails;
    String uid = userData['uid'];
    FireBaseMessagingClass fireBaseMessagingClass = FireBaseMessagingClass();
    fireBaseMessagingClass.FirebaseConfigure();
    fireBaseMessagingClass.getFirebaseToken();
    fireBaseMessagingClass.fcmSubscribe(uid);
    initFunctions();
    super.initState();
  }

  void initFunctions() async {
    _showSpinner = true;
    setState(() {});
    _showSpinner = false;
    setState(() {});
  }

  void getUid() {}

  // Future getUser() async {
  //   final FirebaseUser user = await auth.currentUser();
  //   if (user != null) {
  //     uid = user.uid;
  //     print(" uid  = $uid");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: RefreshProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)),
      inAsyncCall: _showSpinner,
      child:
          // _isAdmin == false
          //     ? LoginScreen()
          Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('Home Screen'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: ExtractedContainer(
                    icon: Icons.featured_play_list,
                    onclick: () async {
//                    var doc = await _firestrore
//                        .collection(
//                            'orders/byTime/${time.toString().substring(0, 10)}')
//                        .getDocuments();
//                    var data = doc.documents;
//                       if (_isAdmin == true) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AllOrders()));
                      // }
                    },
                    text: 'Orders',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: ExtractedContainer(
                    icon: Icons.calculate,
                    onclick: () async {
//                    var doc = await _firestrore
//                        .collection(
//                            'orders/byTime/${time.toString().substring(0, 10)}')
//                        .getDocuments();
//                    var data = doc.documents;
//                       if (_isAdmin == true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalculationScreen()));
                      // }
                    },
                    text: 'Calculation',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
