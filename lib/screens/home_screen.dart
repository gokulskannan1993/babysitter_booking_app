import 'package:babysitter_booking_app/models/babysitter_model.dart';
import 'package:babysitter_booking_app/models/parent_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "home_screen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String state = 'default';
  UserModel user;
  @override
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
    return Scaffold(
        body: FutureBuilder(
            future: _firestore.collection("users").doc(loggedInUser.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // if the snapshot is loading
                return Text("Loading...");
              } else {
                //Mapping all the fields
                Map<String, dynamic> userData = snapshot.data.data();
                if (userData["role"] == "Babysitter") {
                  user = Babysitter();
                } else {
                  user = Parent();
                }
                user.name = userData["name"];
                user.email = userData["email"];
                user.street = userData["street"];
                user.county = userData["county"];
                user.about = userData["about"];
                user.phone = userData["phone"];
                user.followers = userData["followers"];
                user.recommends = userData["recommends"];
                user.rating = userData["rating"];
                return Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(30),
                        height: 75.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CustomLargeButton(
                              minWidth: 100,
                              backgroundColor: state == "profile"
                                  ? kSecondaryColor
                                  : kPrimaryColor,
                              textColor: state == "profile"
                                  ? kPrimaryColor
                                  : kSecondaryColor,
                              btnText: "Profile",
                              onPressed: () {
                                setState(() {
                                  state = 'profile';
                                  Navigator.pushNamed(
                                      context, ProfileScreen.routeName,
                                      arguments: {"user": user});
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CustomLargeButton(
                              minWidth: 100,
                              backgroundColor: state == "default"
                                  ? kSecondaryColor
                                  : kPrimaryColor,
                              textColor: state == "default"
                                  ? kPrimaryColor
                                  : kSecondaryColor,
                              btnText: "Home",
                              onPressed: () {
                                setState(() {
                                  state = 'default';
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CustomLargeButton(
                              minWidth: 100,
                              backgroundColor: state == "browse"
                                  ? kSecondaryColor
                                  : kPrimaryColor,
                              textColor: state == "browse"
                                  ? kPrimaryColor
                                  : kSecondaryColor,
                              btnText: "Browse",
                              onPressed: () {
                                setState(() {
                                  state = 'browse';
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CustomLargeButton(
                              minWidth: 100,
                              backgroundColor: state == "message"
                                  ? kSecondaryColor
                                  : kPrimaryColor,
                              textColor: state == "message"
                                  ? kPrimaryColor
                                  : kSecondaryColor,
                              btnText: "Messages",
                              onPressed: () {
                                setState(() {
                                  state = 'message';
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}
