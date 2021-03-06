import 'dart:ui';
import 'package:intl/intl.dart';

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
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(loggedInUser.uid)
                    .collection('chats')
                    .doc(data['userid'].toString())
                    .collection('data')
                    .orderBy("time")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: kSecondaryColor,
                      ),
                    );
                  } else {
                    final messages = snapshot.data.docs.reversed;
                    List<MessageBubble> messageBubbles = [];
                    for (var message in messages) {
                      final messageText = message.data()["text"];
                      final sender = message.data()["sender"];
                      final date = DateFormat('dd MMMM, yyyy')
                          .format((message.data()["time"].toDate()));
                      final time = DateFormat('hh:mm a')
                          .format((message.data()["time"].toDate()));
                      final status = message.data()["status"];

                      //Marks the message to read by the current user.
                      _firestore
                          .collection('users')
                          .doc(data['userid'].toString())
                          .collection('chats')
                          .doc(loggedInUser.uid)
                          .collection('data')
                          .doc(message.id)
                          .update({'status': "read"});
                      _firestore
                          .collection('users')
                          .doc(loggedInUser.uid)
                          .collection('chats')
                          .doc(data["userid"].toString())
                          .update({'unread': false});
                      //checks if the message is send by the current user that is logged in
                      final isMe = message.data()["sender"] == loggedInUser.uid
                          ? true
                          : false;

                      final messageBubble = MessageBubble(
                        sender: sender,
                        text: messageText,
                        isMe: isMe,
                        date: date,
                        time: time,
                        status: status,
                      );
                      messageBubbles.add(messageBubble);
                    }

                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        children: messageBubbles,
                      ),
                    );
                  }
                },
              ),
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
                            if (messageText.isNotEmpty) {
                              // creates message on the logged in user
                              _firestore
                                  .collection('users')
                                  .doc(loggedInUser.uid)
                                  .collection('chats')
                                  .doc(data["userid"].toString())
                                  .collection('data')
                                  .add({
                                'text': messageText,
                                'sender': loggedInUser.uid,
                                'time': DateTime.now(),
                                'status': "send"
                              }).then((value) => {
                                        // creates message on the target user
                                        _firestore
                                            .collection('users')
                                            .doc(loggedInUser.uid)
                                            .collection('chats')
                                            .doc(data["userid"].toString())
                                            .set({'unread': false}),
                                        _firestore
                                            .collection('users')
                                            .doc(data["userid"])
                                            .collection('chats')
                                            .doc(loggedInUser.uid.toString())
                                            .set({'unread': true}),
                                        _firestore
                                            .collection('users')
                                            .doc(data["userid"])
                                            .collection('chats')
                                            .doc(loggedInUser.uid.toString())
                                            .collection('data')
                                            .doc(value.id)
                                            .set({
                                          'text': messageText,
                                          'sender': loggedInUser.uid,
                                          'time': DateTime.now(),
                                          'status': "send"
                                        })
                                      });
                            }

                            setState(() {
                              messageTextController.clear();
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

// this styles the message bubble in the screen
class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender, this.text, this.isMe, this.date, this.time, this.status});

  final String sender, text, time, date, status;
  final bool isMe;

  Widget statusIcon() {
    if (this.status == "send") {
      return Icon(Icons.done, size: 15, color: kPrimaryColor);
    } else if (this.status == "delivered") {
      return Icon(Icons.done_all, size: 15, color: kPrimaryColor);
    } else {
      return Icon(Icons.done_all, size: 15, color: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            "$time  $date",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(
            height: 4,
          ),
          Material(
            elevation: 10.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            color: isMe ? kSecondaryColor : kPrimaryColor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: 15.0,
                        color: isMe ? kPrimaryColor : kSecondaryColor),
                  ),
                  if (isMe) statusIcon()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
