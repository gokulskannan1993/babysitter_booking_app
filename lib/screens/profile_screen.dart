import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "profile_screen";
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String role,
      username,
      email,
      about,
      phone,
      location,
      rating,
      followers,
      recommends;

  //instance of firestore
  final _firestore = FirebaseFirestore.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

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
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // so that to eliminate the need of hot reload due to async
        future: _firestore.collection("users").doc(loggedInUser.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // if the snapshot is empty
            return Text("Loading...");
          } else {
            //Mapping all the fields
            Map<String, dynamic> userData = snapshot.data.data();
            username = userData["name"];
            role = userData["role"];
            email = userData["email"];
            phone = userData["phone"];
            about = userData["about"];
            location = userData["location"];
            followers = userData["followers"];
            recommends = userData["recommends"];
            rating = userData["rating"];
            return ListView(children: [
              Container(
                color: kSecondaryColor,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Stack(children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              "https://st3.depositphotos.com/15648834/17930/v/1600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg"),
                        ),
                        Positioned(
                            bottom: 3,
                            right: 2,
                            child: CircleAvatar(
                                backgroundColor: kPrimaryColor,
                                radius: 15,
                                child: (Icon(Icons.edit)))),
                      ]),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        username,
                        style: TextStyle(fontSize: 16, color: kPrimaryColor),
                      ),
                      Text(
                        role,
                        style: TextStyle(fontSize: 16, color: kTextColorLight),
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
                          Text(rating),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Followers"),
                          SizedBox(
                            height: 5,
                          ),
                          Text(followers),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Recommends"),
                          SizedBox(
                            height: 5,
                          ),
                          Text(recommends),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Text("User Information"),
                    Divider(),
                    ListTile(
                      title: Text(
                        "Personal Information",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      subtitle: Text(about),
                      leading: Icon(Icons.info),
                    ), // personal info
                    ListTile(
                      title: Text(
                        "Location",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      subtitle: Text(location),
                      leading: Icon(Icons.location_on),
                    ), // location info
                    ListTile(
                      title: Text(
                        "Email",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      subtitle: Text(email),
                      leading: Icon(Icons.email),
                    ), // email
                    ListTile(
                      title: Text(
                        "Phone",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      subtitle: Text(phone),
                      leading: Icon(Icons.phone),
                    ), // phone
                  ],
                ),
              ),
            ]);
          }
        },
      ),
    );
  }
}
