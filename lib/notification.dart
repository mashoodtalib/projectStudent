import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
    // var firebaseUser = FirebaseAuth.instance.currentUser;
    // var _fireStore = FirebaseFirestore.instance;
    // _fireStore.collection('message').doc(firebaseUser!.email).collection('usermes').add({
    //   'body':data,
    //   'timestamp': FieldValue.serverTimestamp(),
    // });
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }

  // Or do other work.
}

class FCM {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  var _fireStore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) async {
        if (message.data.containsKey('data')) {
          // Handle data message
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);

        _fireStore
            .collection('message')
            .doc(firebaseUser!.email)
            .collection('usermes')
            .add({
          'body': message.notification!.body!,
          'timestamp': FieldValue.serverTimestamp(),
        });
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.containsKey('data')) {
        // Handle data message
        streamCtlr.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        // Handle notification message
        streamCtlr.sink.add(message.data['notification']);
      }
      // Or do other work.
      titleCtlr.sink.add(message.notification!.title!);
      bodyCtlr.sink.add(message.notification!.body!);

      _fireStore
          .collection('message')
          .doc(firebaseUser!.email)
          .collection('usermes')
          .add({
        'body': message.notification!.body!,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
    _firebaseMessaging.getToken().then((token) {
      final tokenStr = token.toString();
      _fireStore.collection('token').doc(firebaseUser!.uid).set({
        'email': firebaseUser!.email,
        'tokens': FieldValue.arrayUnion([token])
      });
      // do whatever you want with the token here
      print('token:$token');
    });
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}
