import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_student/loginPage.dart';

import 'Widget/bezierContainer.dart';
import 'notification.dart';

class ChatBox extends StatefulWidget {
  static String id = 'chat';

  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> with WidgetsBindingObserver {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  String notificationTitle = 'No Title';
 late String notificationBody;
  String notificationData = 'No Data';

  @override
  void initState() {
    final firebaseMessaging = FCM();
    firebaseMessaging.setNotifications();

    firebaseMessaging.streamCtlr.stream.listen(_changeData);
    firebaseMessaging.bodyCtlr.stream.listen(_changeBody);
    firebaseMessaging.titleCtlr.stream.listen(_changeTitle);
    WidgetsBinding.instance!.addObserver(this);
    print("InitState");
   // sendMessage();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _fireStore.collection('message').doc(firebaseUser!.email).collection('usermes').add({
    //   'body':notificationBody
    // });
    super.didChangeDependencies();
    print("DidChangeDependencies");
  }

  @override
  void setState(fn) {
    // _fireStore.collection('message').doc(firebaseUser!.email).collection('usermes').add({
    //   'body':notificationBody,
    //   'timestamp': FieldValue.serverTimestamp(),
    //  });
    //_fireStore.collection('message').doc(firebaseUser!.email).collection('usermes').where({
    //
    // });
    print("SetState");
    super.setState(fn);
  }

  @override
  void deactivate() {
    print("Deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        print('appLifeCycleState detached');
        break;
    }
  }

  final _fireStore = FirebaseFirestore.instance;

  _changeData(String msg) => setState(() => notificationData = msg);

  _changeBody(String msg) => setState(() => notificationBody = msg);

  _changeTitle(String msg) => setState(() => notificationTitle = msg);

  Future<void> sendMessage() async {
    await _fireStore
        .collection('message')
        .doc(firebaseUser!.email)
        .collection('usermes')
        .add({
      'body': notificationBody,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'Only',
              style: TextStyle(fontSize: 12, color: Colors.black),
              children: [
                TextSpan(
                  text: ' ADMIN',
                  style: TextStyle(color: Color(0xffe46b10), fontSize: 15),
                ),
                TextSpan(
                  text: ' can send messages',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ]),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, LoginPage.id);
              },
              icon: Icon(Icons.logout),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 80),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xfffbb448), Color(0xfff7892b)])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 0, 2),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      'A',
                      style: TextStyle(fontSize: 20, color: Color(0xffe46b10)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 6, 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              offset: Offset(2, 4),
                              blurRadius: 0.1,
                              spreadRadius: 2)
                        ],
                      ),
                      height: 50,
                      child: _title(),
                    ),
                  ),
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: height * .10,
                    right: -MediaQuery.of(context).size.width * .57,
                    child: BezierContainer(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _fireStore
                            .collection('message')
                            .doc(firebaseUser!.email)
                            .collection('usermes')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            return ListView(
                              children: documents
                                  .map((doc) => Bubble(
                                        margin: BubbleEdges.only(top: 10),
                                        alignment: Alignment.bottomRight,
                                        nipWidth: 8,
                                        nip: BubbleNip.rightTop,
                                        color: Colors.white,
                                        style: BubbleStyle(
                                          shadowColor: Color(0xffe46b10),
                                          elevation: 3,
                                          radius: Radius.circular(10),
                                          nipHeight: 15,
                                          nip: BubbleNip.rightTop,
                                        ),
                                        child: Text(doc['body'],
                                            textAlign: TextAlign.start),
                                      ))
                                  .toList(),
                            );
                          } else {
                            return Center(
                              child: Text('Nothing To Show!'),
                            );
                          }
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
