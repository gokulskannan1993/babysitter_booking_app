import 'dart:ui';

import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  static String routeName = "review_screen";
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentRating = 0;
  String _ratingText = "";

  Map data = {};

  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  //fire auth instance
  final _auth = FirebaseAuth.instance;

  User loggedInUser;

  // void initState() {
  //   super.initState();
  //   getCurrentUser();
  // }
  //
  // //checks for logged in user
  // void getCurrentUser() {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       loggedInUser = user;
  //     } else {
  //       Navigator.pushNamed(context, WelcomeScreen.routeName);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // displays the stars and changes them
  Widget _buildRatingStar(int index) {
    Widget star;

    if (index < _currentRating) {
      star = Icon(
        Icons.star,
        color: kSecondaryColor,
      );
    } else {
      star = Icon(Icons.star_border);
    }
    return GestureDetector(
      child: star,
      onTap: () {
        setState(() {
          _currentRating = index + 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 50),
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      maxLines: 10,
                      decoration: InputDecoration.collapsed(
                          hintText:
                              "What did you think about this Babysitter?"),
                      style: TextStyle(color: kSecondaryColor),
                      onChanged: (value) {
                        _ratingText = value;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rating: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Row(
                      children:
                          List.generate(5, (index) => _buildRatingStar(index)),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomLargeButton(
                      btnText: "Cancel",
                      textColor: kSecondaryColor,
                      backgroundColor: kPrimaryColor,
                      minWidth: 150,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CustomLargeButton(
                      btnText: "Submit",
                      textColor: kPrimaryColor,
                      backgroundColor: kSecondaryColor,
                      minWidth: 150,
                      onPressed: () {},
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
