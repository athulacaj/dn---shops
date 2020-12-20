import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';

final _firestore = Firestore.instance;
String fcmToken;

FirebaseMessaging firebaseMessaging = FirebaseMessaging();
//void navigateToItemDetail=navigateToItemDetail()

class FireBaseMessagingClass {
  FireBaseMessagingClass({this.onclick});
  final Function onclick;
  void FirebaseConfigure() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        AudioCache player = new AudioCache();
        const alarmAudioPath = "sounds/sound.mp3";
        player.play(alarmAudioPath);
        print("onMessage: ${message['data']['page']}");
//        _showItemDialog(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onMessageLaunc: ${message['data']['page']}");
        String _route = await message['data']['page'];
        onclick(_route);
        print('messaging finished');
//         navigateToItemDetail(message);
        //        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        String _route = await message['data']['page'];
        onclick(_route);
        print('messaging finished');

//        _navigateToItemDetail(message);
      },
    );
  }

  void fcmSubscribe(String uid) {
    firebaseMessaging.subscribeToTopic('boys');
    firebaseMessaging.subscribeToTopic('$uid');
  }

  Future<String> getFirebaseToken() async {
    firebaseMessaging.subscribeToTopic('boys');
    firebaseMessaging.getToken().then((token) {
      print(token);
      update(token);
    });
    return await firebaseMessaging.getToken();
  }

  update(String token) {
//    print(token);
//    new DateTime.now()
    var id = token;
    fcmToken = token;

//    _firestore.collection('tokens').document('$id').setData({
//      'token': token,
//    });
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
