import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_student/chat_box.dart';
import 'package:project_student/signup.dart';

import 'Widget/bezierContainer.dart';

class LoginPage extends StatefulWidget {
  static String id = 'log';
 //  LoginPage(this.ui);
 // final String? ui;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    var userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('token').doc(userId).update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  // @override
  // void initState() {
  //   try{
  //     var token = _firebaseMessaging.getToken().then((token) {
  //       saveTokenToDatabase(token!);
  //     });
  //     FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  //   }on Exception catch(e){
  //     showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: Text(' Ops! Something is Wrong'),
  //         content: Text('${e}'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(ctx).pop();
  //             },
  //             child: Text('Okay'),
  //           )
  //         ],
  //       ),
  //     );
  //   }
  //
  //   super.initState();
  // }

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _fireStore = FirebaseFirestore.instance;
  bool loading = false;
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  var firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (formkey.currentState!.validate()) {
          setState(() {
            loading = true;
          });

          try {
            await _auth.signInWithEmailAndPassword(
                email: email, password: password);
            // _firebaseMessaging.getToken().then((token) {
            //   final tokenStr = token.toString();
            //   _fireStore.collection('token').doc(firebaseUser!.uid).set({
            //     'email': email,
            //     'tokens': FieldValue.arrayUnion([token])
            //   });
            //   // do whatever you want with the token here
            // });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.blueGrey,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Login Successful'),
                ),
                duration: Duration(seconds: 5),
              ),
            );

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ChatBox()));
            setState(() {
              loading = false;
            });
          } on FirebaseAuthException catch (e) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(' Ops! Login Failed'),
                content: Text('${e.message}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Okay'),
                  )
                ],
              ),
            );
          }
          setState(() {
            loading = false;
          });
        }
      },
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
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Stu',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xffe46b10)),
          children: [
            TextSpan(
              text: 'de',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'nt',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: formkey,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    validator: (value) =>
                        (value!.isEmpty) ? ' Please enter email' : null,
                    onChanged: (value) {
                      email = value.toString().trim();
                    },
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: _passwordTextController,
                    onChanged: (value) {
                      password = value;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter Password";
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true))
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: -height * .15,
                        right: -MediaQuery.of(context).size.width * .4,
                        child: BezierContainer()),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: height * .2),
                            _title(),
                            SizedBox(height: 50),
                            _emailPasswordWidget(),
                            SizedBox(height: 20),
                            _submitButton(),
                            // Container(
                            //   padding: EdgeInsets.symmetric(vertical: 10),
                            //   alignment: Alignment.centerRight,
                            //   child: Text('Forgot Password ?',
                            //       style: TextStyle(
                            //           fontSize: 14, fontWeight: FontWeight.w500)),
                            // ),
                            // _divider(),
                            // _facebookButton(),
                            // SizedBox(height: height * .055),
                            _createAccountLabel(),
                          ],
                        ),
                      ),
                    ),
                    //  Positioned(top: 40, left: 0, child: _backButton()),
                  ],
                ),
              ));
  }
}
