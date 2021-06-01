import 'dart:io';
import 'package:babysitter_booking_app/screens/all_review_screen.dart';

import 'package:babysitter_booking_app/models/user_model.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/home_screen.dart';
import 'package:babysitter_booking_app/screens/profile_edit_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "profile_screen";
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  //instance of storage
  final _storage = FirebaseStorage.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  UserModel user;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  uploadImage() async {
    final picker = ImagePicker();

    PickedFile image;

    //select image
    image = await picker.getImage(source: ImageSource.gallery);

    var file = File(image.path);

    if (image != null) {
      // upload the image to firebase
      var snapshot = await _storage.ref().child(image.path).putFile(file);
      String url = await snapshot.ref.getDownloadURL();
      _firestore.collection("users").doc(loggedInUser.uid).update({
        "imageUrl": url,
      });
      setState(() {});
    } else {
      print("No path");
    }
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
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pushNamed(context, HomeScreen.routeName);
            },
            color: kSecondaryColor,
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

              return ListView(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Stack(children: [
                          GestureDetector(
                            onTap: () {
                              uploadImage();
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(currentUser["imageUrl"]),
                            ),
                          ),
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          currentUser["name"],
                          style:
                              TextStyle(fontSize: 16, color: kSecondaryColor),
                        ),
                        Text(
                          currentUser["role"] == "Parent"
                              ? "Parent"
                              : "Babysitter",
                          style:
                              TextStyle(fontSize: 16, color: kMediumDarkText),
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AllReviewScreen.routeName,
                                arguments: {'userid': loggedInUser.uid});
                          },
                          child: Column(
                            children: [
                              Text("User Rating"),
                              SizedBox(
                                height: 5,
                              ),
                              Text(currentUser["rating"]),
                            ],
                          ),
                        ),
                        if (currentUser["role"] == "Babysitter")
                          Column(
                            children: [
                              Text("Followers"),
                              SizedBox(
                                height: 5,
                              ),
                              Text(List.from(currentUser["followers"])
                                  .length
                                  .toString()),
                            ],
                          ),
                        Column(
                          children: [
                            Text("Contacts"),
                            SizedBox(
                              height: 5,
                            ),
                            Text(List.from(currentUser["contacts"])
                                .length
                                .toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, ProfileEditScreen.routeName,
                              arguments: {"state": "personalInfo"});
                        },
                        child: ListTile(
                          title: Text(
                            "Personal Information",
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          leading: Icon(Icons.info),
                        ),
                      ), // personal info
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, ProfileEditScreen.routeName,
                              arguments: {"state": "address"});
                        },
                        child: ListTile(
                          title: Text(
                            "Address",
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          subtitle: Text(currentUser["street"] +
                              ", " +
                              currentUser["county"]),
                          leading: Icon(Icons.location_on),
                        ),
                      ), // location info
                      GestureDetector(
                        child: ListTile(
                          title: Text(
                            "Email",
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          subtitle: Text(currentUser["email"]),
                          leading: Icon(Icons.email),
                        ),
                      ), // email
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, ProfileEditScreen.routeName,
                              arguments: {"state": "phone"});
                        },
                        child: ListTile(
                          title: Text(
                            "Phone",
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          subtitle: Text(currentUser["phone"]),
                          leading: Icon(Icons.phone),
                        ),
                      ),
                      // phone
                      GestureDetector(
                        onTap: () {
                          _auth.signOut();
                          Navigator.pushNamed(context, WelcomeScreen.routeName);
                        },
                        child: ListTile(
                          title: Text(
                            "Sign Out",
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          leading: Icon(Icons.logout),
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            }
          },
        ));
  }
}
