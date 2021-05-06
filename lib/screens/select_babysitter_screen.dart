import 'package:babysitter_booking_app/models/jobs_model.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class SelectBabysitter extends StatefulWidget {
  static String routeName = "select_babysitter_screen";
  @override
  _SelectBabysitter createState() => _SelectBabysitter();
}

class _SelectBabysitter extends State<SelectBabysitter> {
  Map data = {};
  String role = "Babysitter";

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
    print(data["maxWage"]);
    return Scaffold(
      body: Container(
        child: StreamBuilder(
            stream: _firestore
                .collection("users")
                .where("role", isEqualTo: "Babysitter")
                .where("wage", isLessThanOrEqualTo: data["maxWage"])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Card> sitterList = [];
                final sitters = snapshot.data.docs;
                for (var sitter in sitters) {
                  final sitterCard = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, UserScreen.routeName);
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(sitter.data()["imageUrl"]),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              Text(
                                "${sitter.data()["name"]}",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                "Rating: ${sitter.data()["rating"]}",
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                "Cost: ${sitter.data()["wage"]}",
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  sitterList.add(sitterCard);
                }
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Column(
                        children: sitterList,
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    "No match Found",
                    style: TextStyle(
                      color: kSecondaryColor,
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
