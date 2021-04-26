import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/login_screen.dart';
import 'package:babysitter_booking_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

import 'widgets/custom_large_button.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'BabyWatch',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Hero(
              tag: "loginTag",
              child: CustomLargeButton(
                textColor: kPrimaryColor,
                backgroundColor: kSecondaryColor,
                btnText: "Login",
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.routeName);
                },
              ),
            ),
            Hero(
              tag: "registerTag",
              child: CustomLargeButton(
                textColor: kPrimaryColor,
                backgroundColor: kSecondaryColor,
                btnText: "Register",
                onPressed: () {
                  Navigator.pushNamed(context, RegisterScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
