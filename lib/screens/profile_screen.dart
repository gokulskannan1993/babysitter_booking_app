import 'dart:io';

import 'package:babysitter_booking_app/models/babysitter_model.dart';
import 'package:babysitter_booking_app/models/parent_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/profile_edit_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "profile_screen";
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //for showing the data on the fields
  String role,
      username,
      email,
      about,
      phone,
      location,
      rating,
      followers,
      recommends;

  Map data = {};
  UserModel user;

  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  //instance of storage
  final _storage = FirebaseStorage.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

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
      _firestore.collection("users").doc(user.id).update({
        "imageUrl": url,
      });
      setState(() {
        user.profileImage = url;
      });
    } else {
      print("No path");
    }
  }

  //checks for logged in user
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Navigator.pushNamed(context, WelcomeScreen.routeName);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    user = data['user'];

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: kSecondaryColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(children: [
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
                        backgroundImage: NetworkImage(user.profileImage),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    user.name,
                    style: TextStyle(fontSize: 16, color: kSecondaryColor),
                  ),
                  Text(
                    role = user is Parent ? "Parent" : "Babysitter",
                    style: TextStyle(fontSize: 16, color: kMediumDarkText),
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
                  Column(
                    children: [
                      Text("User Rating"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(user.rating),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Followers"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(user.followers),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Recommends"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(user.recommends),
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
                    Navigator.pushNamed(context, ProfileEditScreen.routeName,
                        arguments: {"user": user, "state": "personalInfo"});
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
                    Navigator.pushNamed(context, ProfileEditScreen.routeName,
                        arguments: {"user": user, "state": "address"});
                  },
                  child: ListTile(
                    title: Text(
                      "Address",
                      style: TextStyle(color: kSecondaryColor),
                    ),
                    subtitle: Text(user.street + ", " + user.county),
                    leading: Icon(Icons.location_on),
                  ),
                ), // location info
                GestureDetector(
                  child: ListTile(
                    title: Text(
                      "Email",
                      style: TextStyle(color: kSecondaryColor),
                    ),
                    subtitle: Text(user.email),
                    leading: Icon(Icons.email),
                  ),
                ), // email
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProfileEditScreen.routeName,
                        arguments: {"user": user, "state": "phone"});
                  },
                  child: ListTile(
                    title: Text(
                      "Phone",
                      style: TextStyle(color: kSecondaryColor),
                    ),
                    subtitle: Text(user.phone),
                    leading: Icon(Icons.phone),
                  ),
                ),
                if (user is Babysitter)
                  GestureDetector(
                    child: ListTile(
                      title: Text(
                        "Availability",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      leading: Icon(Icons.settings),
                    ),
                  ), // phone
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
        ]));
  }
}
