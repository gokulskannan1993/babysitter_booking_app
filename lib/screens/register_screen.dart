import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class RegisterScreen extends StatefulWidget {
  static String routeName = "register_screen";
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  //instance for firebase auth
  final _auth = FirebaseAuth.instance;
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  String email, password, confirmPass;
  bool isParent = false;
  bool _saving = false;
  String roleString = "I am a Babysitter";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Padding(
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
                  isObscure: true,
                  onChanged: (value) {
                    confirmPass = value;
                  },
                ), // confirm password
                SizedBox(
                  height: 24.0,
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
                    btnText: "Register",
                    onPressed: () async {
                      //for the spinner
                      setState(() {
                        _saving = true;
                      });
                      try {
                        //creating the new user at auth
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          //create an entry of the user in the firestore
                          _firestore
                              .collection("users")
                              .doc(newUser.user.uid)
                              .set({
                            'name': "Anonymous",
                            'email': email,
                            'role': isParent ? "Parent" : "Babysitter",
                            'about': "Add Detail Here",
                            'location': "Add Location",
                            'phone': "Add Phone",
                            'followers': "0",
                            "recommends": "0",
                            "rating": "0"
                          });

                          Navigator.pushNamed(context, ProfileScreen.routeName);
                        }
                        //for the spinner
                        setState(() {
                          _saving = false;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ), // Register Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
