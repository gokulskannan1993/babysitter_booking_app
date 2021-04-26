import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = "register_screen";
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  // final _auth = FirebaseAuth.instance;
  String email, password, confirmPass;
  bool isParent = false;
  String roleString = "I am a Babysitter";
  @override
  Widget build(BuildContext context) {
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
              ), //Enter email
              SizedBox(
                height: 8.0,
              ),
              CustomLargeTextField(
                hintText: "Confirm Password",
                isObscure: true,
              ), //Enter Password
              SizedBox(
                height: 8.0,
              ),
              CustomLargeTextField(
                hintText: "Confirm Password",
                isObscure: true,
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
                  }),
              SizedBox(
                height: 24.0,
              ),
              Hero(
                tag: "registerTag",
                child: CustomLargeButton(
                  textColor: kPrimaryColor,
                  backgroundColor: kSecondaryColor,
                  btnText: "Register",
                ),
              ), // Register Button
            ],
          ),
        ),
      ),
    );
  }
}
