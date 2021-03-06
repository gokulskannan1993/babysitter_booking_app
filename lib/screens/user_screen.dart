import 'dart:ui';

import 'package:babysitter_booking_app/screens/chat_screen.dart';
import 'package:babysitter_booking_app/screens/all_review_screen.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/review_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'contact_card_screen.dart';

class UserScreen extends StatefulWidget {
  static String routeName = "user_screen";
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map data = {};

  //instance of firestore
  final _firestore = FirebaseFirestore.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;

  bool hasJob = false;

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

  checkUserJobs(String userid) {
    _firestore
        .collection('jobs')
        .where('creator', isEqualTo: loggedInUser.uid)
        .get()
        .then((QuerySnapshot snapshot) => {
              for (var job in snapshot.docs)
                {
                  if (job["assignedTo"] == userid) {hasJob = true}
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    checkUserJobs(data["userid"]);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: kSecondaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _firestore.collection("users").doc(loggedInUser.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // if the snapshot is loading
            return Text("Loading...");
          } else {
            Map<String, dynamic> currentUser = snapshot.data.data();
            return FutureBuilder(
              future: _firestore.collection("users").doc(data["userid"]).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // if the snapshot is loading
                  return Text("Loading...");
                } else {
                  Map<String, dynamic> profileUser = snapshot.data.data();
                  return ListView(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.27,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(profileUser["imageUrl"]),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    profileUser["name"],
                                    style: TextStyle(
                                        fontSize: 16, color: kSecondaryColor),
                                  ),
                                  Text(
                                    profileUser["county"],
                                    style: TextStyle(
                                        fontSize: 16, color: kMediumDarkText),
                                  ),
                                ],
                              ),
                              if (profileUser["role"] == "Babysitter" &&
                                  loggedInUser.uid != data['userid'])
                                CustomLargeButton(
                                  textColor: kSecondaryColor,
                                  backgroundColor: kPrimaryColor,
                                  btnText: "Give Feedback",
                                  minWidth: 100,
                                  onPressed: () {
                                    if (hasJob) {
                                      Navigator.pushNamed(
                                          context, ReviewScreen.routeName,
                                          arguments: {
                                            'userid': data["userid"]
                                          });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "You don't have any jobs with this babysitter",
                                          style:
                                              TextStyle(color: kPrimaryColor),
                                        ),
                                      ));
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (profileUser["role"] == "Babysitter")
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AllReviewScreen.routeName,
                                        arguments: {'userid': data["userid"]});
                                  },
                                  child: Column(
                                    children: [
                                      Text("User Rating"),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(profileUser["rating"]),
                                    ],
                                  ),
                                ),
                              if (profileUser["role"] == "Parent")
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, ContactCardScreen.routeName,
                                        arguments: {
                                          'users': profileUser['contacts']
                                        }).then((value) => {
                                          setState(() {
                                            // refresh state of Page1
                                          })
                                        });
                                  },
                                  child: Column(
                                    children: [
                                      Text("Contacts"),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(List.from(profileUser["contacts"])
                                          .length
                                          .toString()),
                                    ],
                                  ),
                                ),
                              if (profileUser["role"] == "Babysitter")
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, ContactCardScreen.routeName,
                                        arguments: {
                                          'users': profileUser['followers']
                                        }).then((value) => {
                                          setState(() {
                                            // refresh state of Page1
                                          })
                                        });
                                  },
                                  child: Column(
                                    children: [
                                      Text("Followers"),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(List.from(profileUser["followers"])
                                          .length
                                          .toString()),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (data["userid"] != loggedInUser.uid)
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (profileUser["role"] == "Babysitter")
                                CustomLargeButton(
                                  textColor: kSecondaryColor,
                                  backgroundColor: kPrimaryColor,
                                  btnText: List.from(currentUser["contacts"])
                                          .contains(data["userid"])
                                      ? "Unfollow"
                                      : "Follow",
                                  minWidth: 150,
                                  onPressed: () {
                                    if (List.from(currentUser["contacts"])
                                        .contains(data["userid"])) {
                                      _firestore
                                          .collection("users")
                                          .doc(loggedInUser.uid)
                                          .update({
                                        "contacts": FieldValue.arrayRemove(
                                            [data["userid"]])
                                      });
                                      _firestore
                                          .collection("users")
                                          .doc(data["userid"])
                                          .update({
                                        "followers": FieldValue.arrayRemove(
                                            [loggedInUser.uid])
                                      });
                                    } else {
                                      _firestore
                                          .collection("users")
                                          .doc(loggedInUser.uid)
                                          .update({
                                        "contacts": FieldValue.arrayUnion(
                                            [data["userid"]])
                                      });
                                      _firestore
                                          .collection("users")
                                          .doc(data["userid"])
                                          .update({
                                        "followers": FieldValue.arrayUnion(
                                            [loggedInUser.uid])
                                      });
                                    }

                                    setState(() {});
                                  },
                                ),
                              CustomLargeButton(
                                textColor: kSecondaryColor,
                                backgroundColor: kPrimaryColor,
                                btnText: "Message",
                                minWidth: 150,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, ChatScreen.routeName,
                                      arguments: {"userid": data["userid"]});
                                },
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 16,
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (profileUser["role"] == "Parent")
                                Text(
                                  "Number of kids: ${List.from(profileUser["children"]).length}",
                                  style: TextStyle(
                                      fontSize: 15, color: kSecondaryColor),
                                ),
                              if (profileUser["role"] == "Babysitter")
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Maximum number of kids: ${profileUser["maxNoofChildren"]}",
                                      style: TextStyle(
                                          fontSize: 15, color: kSecondaryColor),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Maximum Age:    ${profileUser["maxAgeofChild"]}",
                                      style: TextStyle(
                                          fontSize: 15, color: kSecondaryColor),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Minimum Age:    ${profileUser["minAgeofChild"]}",
                                      style: TextStyle(
                                          fontSize: 15, color: kSecondaryColor),
                                    ),
                                  ],
                                ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "About",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: kSecondaryColor),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                profileUser["about"],
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: kSecondaryColor),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
