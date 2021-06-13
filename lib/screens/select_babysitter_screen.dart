import 'package:babysitter_booking_app/screens/job_detail_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    List askedUsers = data["askedUsers"];
    List askedBy = data["askedBy"];

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: kSecondaryColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _firestore.collection("users").doc(loggedInUser.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // if the snapshot is loading
              return Text("Loading...");
            } else {
              Map<String, dynamic> currentUser = snapshot.data.data();
              List contacts = currentUser["contacts"];

              return Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      if (contacts.isNotEmpty)
                        StreamBuilder(
                            stream: _firestore
                                .collection("users")
                                .where("role", isEqualTo: "Babysitter")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<Card> sitterList = [];
                                final sitters = snapshot.data.docs;
                                for (var sitter in sitters) {
                                  if (sitter.data()["wage"] <=
                                          data["maxWage"] &&
                                      !askedUsers.contains(sitter.id) &&
                                      !askedBy.contains(sitter.id) &&
                                      contacts.contains(sitter.id)) {
                                    final sitterCard = Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    UserScreen.routeName,
                                                    arguments: {
                                                      "userid": sitter.id,
                                                    }).then((value) => {
                                                      setState(() {
                                                        // refresh state of Page1
                                                      })
                                                    });
                                              },
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    sitter.data()["imageUrl"]),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "${sitter.data()["name"]}",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  "Rating: ${sitter.data()["rating"]}/10",
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            CustomLargeButton(
                                              textColor: kSecondaryColor,
                                              backgroundColor: kPrimaryColor,
                                              btnText: "Ask",
                                              minWidth: 100,
                                              onPressed: () {
                                                _firestore
                                                    .collection("jobs")
                                                    .doc(data["jobID"])
                                                    .update({
                                                  "askedTo":
                                                      FieldValue.arrayUnion(
                                                          [sitter.id])
                                                });
                                                _firestore
                                                    .collection("users")
                                                    .doc(sitter.id)
                                                    .update({
                                                  "offeredJobs":
                                                      FieldValue.arrayUnion(
                                                          [data["jobID"]]),
                                                  "hasNewOffer": true
                                                });

                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    JobDetailScreen.routeName,
                                                    arguments: {
                                                      "job": data["jobID"]
                                                    });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                    sitterList.add(sitterCard);
                                  }
                                }
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Column(
                                        children: sitterList,
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                );
                              }
                            }),
                    ],
                  ),
                  StreamBuilder(
                      stream: _firestore
                          .collection("users")
                          .where("role", isEqualTo: "Babysitter")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Card> sitterList = [];
                          final sitters = snapshot.data.docs;
                          for (var sitter in sitters) {
                            if (sitter.data()["wage"] <= data["maxWage"] &&
                                !askedUsers.contains(sitter.id) &&
                                !askedBy.contains(sitter.id) &&
                                !contacts.contains(sitter.id)) {
                              final sitterCard = Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, UserScreen.routeName,
                                              arguments: {
                                                "userid": sitter.id,
                                              }).then((value) => {
                                                setState(() {
                                                  // refresh state of Page1
                                                })
                                              });
                                        },
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                              sitter.data()["imageUrl"]),
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
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "Rating: ${sitter.data()["rating"]}/10",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      CustomLargeButton(
                                        textColor: kSecondaryColor,
                                        backgroundColor: kPrimaryColor,
                                        btnText: "Ask",
                                        minWidth: 100,
                                        onPressed: () {
                                          _firestore
                                              .collection("jobs")
                                              .doc(data["jobID"])
                                              .update({
                                            "askedTo": FieldValue.arrayUnion(
                                                [sitter.id])
                                          });
                                          _firestore
                                              .collection("users")
                                              .doc(sitter.id)
                                              .update({
                                            "offeredJobs":
                                                FieldValue.arrayUnion(
                                                    [data["jobID"]]),
                                            "hasNewOffer": true
                                          });

                                          Navigator.pushReplacementNamed(
                                              context,
                                              JobDetailScreen.routeName,
                                              arguments: {
                                                "job": data["jobID"]
                                              });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                              sitterList.add(sitterCard);
                            }
                          }
                          return Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Column(
                                  children: sitterList,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              "",
                              style: TextStyle(
                                color: kSecondaryColor,
                              ),
                            ),
                          );
                        }
                      }),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
