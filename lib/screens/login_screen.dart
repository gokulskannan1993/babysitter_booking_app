import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'constants.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
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
                hintText: "Enter your email",
                inputType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 8.0,
              ),
              CustomLargeTextField(
                hintText: "Enter your Password",
                isObscure: true,
              ),
              SizedBox(
                height: 24.0,
              ),
              Hero(
                tag: "loginTag",
                child: CustomLargeButton(
                  textColor: kPrimaryColor,
                  backgroundColor: kSecondaryColor,
                  btnText: "Login",
                  onPressed: () async {
                    setState(() {
                      _saving = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
