import 'dart:ui';

import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText;

  Map data = {};

  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  //fire auth instance
  final _auth = FirebaseAuth.instance;

  User loggedInUser;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  //checks for logged in user
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      } else {
        Navigator.pushNamed(context, WelcomeScreen.routeName);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: kSecondaryColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(),
              Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: kSecondaryColor, width: 2.0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            hintText: 'Type your message here...',
                            border: InputBorder.none,
                          ),
                          controller: messageTextController,
                          onChanged: (value) {
                            messageText = value;
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            _firestore
                                .collection('users')
                                .doc(loggedInUser.uid)
                                .collection(data["userid"].toString())
                                .add({
                              'message': messageText,
                              'sender': loggedInUser.uid
                            });
                            _firestore
                                .collection('users')
                                .doc(data["userid"])
                                .collection(loggedInUser.uid.toString())
                                .add({
                              'message': messageText,
                              'sender': loggedInUser.uid
                            });
                            setState(() {
                              messageTextController.text = "";
                            });
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(
                              color: kSecondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ))
                    ],
                  ))
            ],
          ),
        ));
  }
}
