import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactCardScreen extends StatefulWidget {
  static String routeName = "contact_card_screen";
  @override
  _ContactCardScreenState createState() => _ContactCardScreenState();
}

class _ContactCardScreenState extends State<ContactCardScreen> {
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
    List users = List.from(data["users"]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            for (var user in users)
              FutureBuilder(
                future: _firestore.collection('users').doc(user).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // if the snapshot is loading
                    return Text("Loading...");
                  } else {
                    Map<String, dynamic> userData = snapshot.data.data();
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, UserScreen.routeName, arguments: {
                          'userid': user
                        }).then((value) => {
                              setState(() {
                                // refresh state of Page1
                              })
                            });
                      },
                      child: Card(
                        elevation: 10,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(userData["imageUrl"]),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${userData["name"]}",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            if (users.isEmpty)
              SizedBox(
                height: 250,
              ),
            if (users.isEmpty)
              Center(
                child: Text("No Users Found"),
              )
          ],
        ),
      ),
    );
  }
}
