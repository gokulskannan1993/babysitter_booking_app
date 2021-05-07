import 'package:babysitter_booking_app/models/babysitter_model.dart';
import 'package:babysitter_booking_app/models/parent_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/home_screen.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:numberpicker/numberpicker.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = "register_screen";
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  //To change state
  String state = "email";
  //instance for firebase auth
  final _auth = FirebaseAuth.instance;
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  UserModel user;

  String email,
      password,
      name,
      address,
      street,
      county,
      about,
      confirmPassword,
      phone;
  int minWage = 10;
  bool isParent = false;
  bool saving = false;
  String roleString = "I am a Babysitter";
  @override
  Widget build(BuildContext context) {
    if (state == "email") {
      return Scaffold(
        backgroundColor: kPrimaryColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 150.0,
                ),
                SizedBox(
                  height: 48.0,
                ),
                CustomLargeTextField(
                  hintText: "Enter your email",
                  inputType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                ), //Enter email
                SizedBox(
                  height: 8.0,
                ),
                CustomLargeTextField(
                  hintText: "Enter Password",
                  isObscure: true,
                  onChanged: (value) {
                    password = value;
                  },
                ), //Enter Password
                SizedBox(
                  height: 8.0,
                ),

                CustomLargeTextField(
                  hintText: "Confirm Password",
                  inputType: TextInputType.phone,
                  onChanged: (value) {
                    confirmPassword = value;
                  },
                ), // confirm password
                SizedBox(
                  height: 8.0,
                ),
                SwitchListTile(
                    title: Text(
                      roleString,
                      style: TextStyle(
                        color: kMediumDarkText,
                      ),
                    ),
                    activeColor: kSecondaryColor,
                    inactiveThumbColor: kSecondaryColor,
                    value: isParent,
                    onChanged: (bool value) {
                      setState(() {
                        isParent = value;
                        roleString =
                            value ? "I am a Parent" : "I am a Babysitter";
                      });
                    }), // isParent
                SizedBox(
                  height: 24.0,
                ),
                Hero(
                  tag: "registerTag",
                  child: CustomLargeButton(
                    textColor: kPrimaryColor,
                    backgroundColor: kSecondaryColor,
                    btnText: "Next",
                    onPressed: () {
                      if (isParent) {
                        user = Parent();
                      } else {
                        user = Babysitter();
                      }
                      if (confirmPassword == password) {
                        user.email = email;
                        user.password = password;
                        setState(() {
                          state = "details";
                        });
                      }
                    },
                    // onPressed: () async {
                    //   //for the spinner
                    //   setState(() {
                    //     saving = true;
                    //   });
                    //   try {
                    //     //creating the new user at auth
                    //     final newUser =
                    //         await _auth.createUserWithEmailAndPassword(
                    //             email: email, password: password);
                    //     if (newUser != null) {
                    //       //create an entry of the user in the firestore
                    //       _firestore
                    //           .collection("users")
                    //           .doc(newUser.user.uid)
                    //           .set({
                    //         'name': name,
                    //         'email': email,
                    //         'role': isParent ? "Parent" : "Babysitter",
                    //         'about': "Add Detail Here",
                    //         'location': address,
                    //         'phone': phone,
                    //         'followers': "0",
                    //         "recommends": "0",
                    //         "rating": "0",
                    //       });
                    //
                    //       Navigator.pushNamed(
                    //           context, ProfileScreen.routeName);
                    //     }
                    //     //for the spinner
                    //     setState(() {
                    //       saving = false;
                    //     });
                    //   } catch (e) {
                    //     print(e);
                    //   }
                    // },
                  ),
                ), // Register Button
              ],
            ),
          ),
        ),
      );
    } else if (state == "details") {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                SizedBox(
                  height: 48.0,
                ),
                CustomLargeTextField(
                  hintText: "Enter your name",
                  onChanged: (value) {
                    name = value;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                CustomLargeTextField(
                  hintText: "Enter your Street Address",
                  onChanged: (value) {
                    street = value;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                CustomLargeTextField(
                  hintText: "Enter your County",
                  onChanged: (value) {
                    county = value;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                CustomLargeTextField(
                  hintText: "Enter phone number",
                  onChanged: (value) {
                    phone = value;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomLargeButton(
                      minWidth: 150,
                      textColor: kSecondaryColor,
                      backgroundColor: kPrimaryColor,
                      btnText: "Back",
                      onPressed: () {
                        setState(() {
                          state = "email";
                        });
                      },
                    ),
                    CustomLargeButton(
                      minWidth: 150,
                      textColor: kPrimaryColor,
                      backgroundColor: kSecondaryColor,
                      btnText: "Next",
                      onPressed: () {
                        user.name = name;
                        user.street = street;
                        user.county = county;
                        user.phone = phone;
                        setState(() {
                          state = "about";
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return ModalProgressHUD(
        inAsyncCall: saving,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 85.0,
                    ),
                    Text(
                      user is Parent ? 'About my child' : "About me",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kSecondaryColor),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          maxLines: 10,
                          decoration: InputDecoration.collapsed(
                              hintText: "Enter your text here"),
                          style: TextStyle(color: kSecondaryColor),
                          onChanged: (value) {
                            setState(() {
                              about = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    if (user is Babysitter)
                      ListTile(
                        title: Text(
                          "Select Minimum wage per hour (£)",
                          style:
                              TextStyle(color: kSecondaryColor, fontSize: 20),
                        ),
                      ),
                    NumberPicker(
                        axis: Axis.horizontal,
                        minValue: 10,
                        maxValue: 100,
                        value: minWage,
                        onChanged: (value) {
                          setState(() {
                            minWage = value;
                          });
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomLargeButton(
                          minWidth: 150,
                          textColor: kSecondaryColor,
                          backgroundColor: kPrimaryColor,
                          btnText: "Back",
                          onPressed: () {
                            setState(() {
                              state = "details";
                            });
                          },
                        ),
                        CustomLargeButton(
                          minWidth: 150,
                          textColor: kPrimaryColor,
                          backgroundColor: kSecondaryColor,
                          btnText: "Register",
                          onPressed: () async {
                            user.about = about;

                            //for the spinner
                            setState(() {
                              saving = true;
                            });
                            try {
                              //creating the new user at auth
                              final newUser =
                                  await _auth.createUserWithEmailAndPassword(
                                      email: user.email,
                                      password: user.password);
                              if (newUser != null) {
                                //create an entry of the user in the firestore
                                user.id = newUser.user.uid;

                                if (user is Parent) {
                                  _firestore
                                      .collection("users")
                                      .doc(user.id)
                                      .set({
                                    'name': user.name,
                                    'email': user.email,
                                    'role': "Parent",
                                    'about': user.about,
                                    'street': user.street,
                                    'county': user.county,
                                    'phone': user.phone,
                                    'imageUrl': user.profileImage,
                                    'followers': "0",
                                    "recommends": "0",
                                    "rating": "0",
                                  });
                                } else {
                                  Babysitter bs = user;
                                  bs.wage = minWage;
                                  _firestore
                                      .collection("users")
                                      .doc(bs.id)
                                      .set({
                                    'name': bs.name,
                                    'email': bs.email,
                                    'role': "Babysitter",
                                    'about': bs.about,
                                    'street': bs.street,
                                    'county': bs.county,
                                    'phone': bs.phone,
                                    'wage': bs.wage,
                                    'imageUrl': user.profileImage,
                                    'followers': "0",
                                    "recommends": "0",
                                    "rating": "0",
                                  });
                                }

                                Navigator.pushNamed(
                                    context, HomeScreen.routeName);
                              }
                              //for the spinner
                              setState(() {
                                saving = false;
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
