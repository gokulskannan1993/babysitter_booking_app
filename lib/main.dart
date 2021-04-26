import 'package:babysitter_booking_app/screens/home_screen.dart';
import 'package:babysitter_booking_app/screens/login_screen.dart';
import 'package:babysitter_booking_app/screens/map_screen.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/register_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(BabysitterBookingApp());

class BabysitterBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
          textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black54),
        bodyText2: TextStyle(color: Colors.black54),
      )),

      //Routing to Different Screens
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        MapScreen.routeName: (context) => MapScreen(),
        UserScreen.routeName: (context) => UserScreen(),
      },
    );
  }
}
