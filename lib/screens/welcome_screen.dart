import 'package:babysitter_booking_app/screens/login_screen.dart';
import 'package:babysitter_booking_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

import 'components/loginregisterationbutton.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = "welcome_screen";
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
                  'Baby Watch',
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
              child: LoginRegisterButton(
                textColor: Colors.white,
                backgroundColor: Colors.lightBlueAccent,
                btnText: "Login",
                targetScreen: LoginScreen.id,
              ),
            ),
            Hero(
              tag: "registerTag",
              child: LoginRegisterButton(
                textColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                btnText: "Register",
                targetScreen: RegisterScreen.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
