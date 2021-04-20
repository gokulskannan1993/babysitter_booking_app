import 'package:babysitter_booking_app/screens/login_screen.dart';
import 'package:babysitter_booking_app/screens/register_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(BabysitterBookingApp());

class BabysitterBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
          textTheme: TextTheme(
        bodyText2: TextStyle(color: Colors.black54),
      )),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
      },
    );
  }
}
