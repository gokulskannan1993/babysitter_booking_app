import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:babysitter_booking_app/services/location_reroute.dart';
import 'package:babysitter_booking_app/services/validation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:numberpicker/numberpicker.dart';

import 'constants.dart';

class ProfileEditScreen extends StatefulWidget {
  static String routeName = "profile_edit_screen";
  @override
  _ProfileEditScreen createState() => _ProfileEditScreen();
}

class _ProfileEditScreen extends State<ProfileEditScreen> {
  Map data = {};
  var _formKey = GlobalKey<FormState>();

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
      body: FutureBuilder(
        future: _firestore.collection("users").doc(loggedInUser.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // if the snapshot is loading
            return Text("Loading...");
          } else {
            //Mapping all the fields
            Map<String, dynamic> currentUser = snapshot.data.data();
            return Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    if (data["state"] == "personalInfo")
                      Container(
                        // Edit Personal Information
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  "Edit Personal Info",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListTile(
                                title: Text(
                                  "Edit Name",
                                  style: TextStyle(
                                      color: kSecondaryColor, fontSize: 20),
                                ),
                              ),
                              CustomLargeTextField(
                                validator: (String value) {
                                  if (value.isEmpty)
                                    return "Name cannot be empty";
                                },
                                hintText: currentUser["name"],
                                onChanged: (value) {
                                  currentUser["name"] = value;
                                },
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              ListTile(
                                title: Text(
                                  currentUser["role"] == "Parent"
                                      ? "Change About my child"
                                      : " Change About me",
                                  style: TextStyle(
                                      color: kSecondaryColor, fontSize: 20),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    maxLines: 10,
                                    decoration: InputDecoration.collapsed(
                                        hintText: currentUser["about"]),
                                    style: TextStyle(color: kSecondaryColor),
                                    onChanged: (value) {
                                      currentUser["about"] = value;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                    btnText: "Update",
                                    textColor: kSecondaryColor,
                                    backgroundColor: kPrimaryColor,
                                    minWidth: 150,
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _firestore
                                            .collection("users")
                                            .doc(loggedInUser.uid)
                                            .update({
                                          "name": currentUser["name"],
                                          "about": currentUser["about"]
                                        });
                                        Navigator.pushReplacementNamed(
                                          context,
                                          ProfileScreen.routeName,
                                        );
                                      }
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    if (data["state"] == "address")
                      Container(
                        // to edit address
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Edit Address Info",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              CustomLargeButton(
                                textColor: kSecondaryColor,
                                backgroundColor: kPrimaryColor,
                                btnText: "Show on Map",
                                onPressed: () {
                                  launchLocation(
                                      "${currentUser['street']},  ${currentUser['county']}");
                                },
                              ),
                              ListTile(
                                title: Text(
                                  "Edit Street",
                                  style: TextStyle(
                                      color: kSecondaryColor, fontSize: 20),
                                ),
                              ),
                              CustomLargeTextField(
                                validator: (String value) {
                                  if (value.isEmpty)
                                    return "Street address cannot be empty";
                                },
                                hintText: currentUser["street"],
                                onChanged: (value) {
                                  currentUser["street"] = value;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListTile(
                                title: Text(
                                  "Edit County",
                                  style: TextStyle(
                                      color: kSecondaryColor, fontSize: 20),
                                ),
                              ),
                              CustomLargeTextField(
                                validator: (String value) {
                                  if (value.isEmpty)
                                    return "County cannot be empty";
                                },
                                hintText: currentUser["county"],
                                onChanged: (value) {
                                  currentUser["county"] = value;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                    btnText: "Update",
                                    textColor: kSecondaryColor,
                                    backgroundColor: kPrimaryColor,
                                    minWidth: 150,
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _firestore
                                            .collection("users")
                                            .doc(loggedInUser.uid)
                                            .update({
                                          "street": currentUser["street"],
                                          "county": currentUser["county"]
                                        });
                                        Navigator.pushReplacementNamed(
                                          context,
                                          ProfileScreen.routeName,
                                        );
                                      }
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    if (data["state"] == "phone")
                      Container(
                        // to edit address
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              ListTile(
                                title: Text(
                                  "Edit Phone Number",
                                  style: TextStyle(
                                      color: kSecondaryColor, fontSize: 20),
                                ),
                              ),
                              CustomLargeTextField(
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return "Phone number cannot be empty";
                                  } else if (mobileNumberValidator(value)) {
                                    return "Please enter a valid mobile number";
                                  }
                                },
                                hintText: currentUser["phone"],
                                onChanged: (value) {
                                  currentUser["phone"] = value;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                    btnText: "Update",
                                    textColor: kSecondaryColor,
                                    backgroundColor: kPrimaryColor,
                                    minWidth: 150,
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _firestore
                                            .collection("users")
                                            .doc(loggedInUser.uid)
                                            .update({
                                          "phone": currentUser["phone"]
                                        });
                                        Navigator.pushReplacementNamed(
                                          context,
                                          ProfileScreen.routeName,
                                        );
                                      }
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    if (data["state"] == "preferences")
                      Container(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 10,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Minimum wage per hour (€)   ",
                                        style: TextStyle(
                                            color: kSecondaryColor,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      NumberInputWithIncrementDecrement(
                                        controller: TextEditingController(),
                                        min: 10,
                                        max: 100,
                                        initialValue: currentUser["wage"],
                                        autovalidate: true,
                                        onIncrement: (value) {
                                          currentUser['wage'] = value;
                                        },
                                        onDecrement: (value) {
                                          currentUser['wage'] = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 10,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Minimum age of child:      ",
                                        style: TextStyle(
                                            color: kSecondaryColor,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      NumberInputWithIncrementDecrement(
                                        controller: TextEditingController(),
                                        min: 0,
                                        max: 15,
                                        initialValue:
                                            currentUser["minAgeofChild"],
                                        onIncrement: (value) {
                                          currentUser['minAgeofChild'] = value;
                                        },
                                        onDecrement: (value) {
                                          currentUser['minAgeofChild'] = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 10,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Maximum age of child      ",
                                        style: TextStyle(
                                            color: kSecondaryColor,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      NumberInputWithIncrementDecrement(
                                        controller: TextEditingController(),
                                        min: 0,
                                        max: 15,
                                        initialValue:
                                            currentUser["maxAgeofChild"],
                                        onIncrement: (value) {
                                          currentUser['maxAgeofChild'] = value;
                                        },
                                        onDecrement: (value) {
                                          currentUser['maxAgeofChild'] = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 10,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Maximum Number of children   ",
                                        style: TextStyle(
                                            color: kSecondaryColor,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      NumberInputWithIncrementDecrement(
                                        controller: TextEditingController(),
                                        min: 1,
                                        max: 5,
                                        initialValue:
                                            currentUser["maxNoofChildren"],
                                        onIncrement: (value) {
                                          currentUser['maxNoofChildren'] =
                                              value;
                                        },
                                        onDecrement: (value) {
                                          currentUser['maxNoofChildren'] =
                                              value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                    btnText: "Update",
                                    textColor: kSecondaryColor,
                                    backgroundColor: kPrimaryColor,
                                    minWidth: 150,
                                    onPressed: () {
                                      _firestore
                                          .collection("users")
                                          .doc(loggedInUser.uid)
                                          .update({
                                        "minAgeofChild":
                                            currentUser["minAgeofChild"],
                                        "maxAgeofChild":
                                            currentUser["maxAgeofChild"],
                                        "maxNoofChildren":
                                            currentUser["maxNoofChildren"],
                                        "wage": currentUser["wage"]
                                      });
                                      Navigator.pushReplacementNamed(
                                        context,
                                        ProfileScreen.routeName,
                                      );
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
