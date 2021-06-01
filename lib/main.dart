import 'package:babysitter_booking_app/screens/chat_screen.dart';
import 'package:babysitter_booking_app/screens/home_screen.dart';
import 'package:babysitter_booking_app/screens/job_detail_screen.dart';
import 'package:babysitter_booking_app/screens/login_screen.dart';
import 'package:babysitter_booking_app/screens/map_screen.dart';
import 'package:babysitter_booking_app/screens/profile_edit_screen.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/register_screen.dart';
import 'package:babysitter_booking_app/screens/review_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:babysitter_booking_app/screens/add_job_screen.dart';
import 'package:babysitter_booking_app/screens/select_babysitter_screen.dart';
import 'package:babysitter_booking_app/screens/all_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BabysitterBookingApp());
}

class BabysitterBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        AddJobScreen.routeName: (context) => AddJobScreen(),
        SelectBabysitter.routeName: (context) => SelectBabysitter(),
        ProfileEditScreen.routeName: (context) => ProfileEditScreen(),
        JobDetailScreen.routeName: (context) => JobDetailScreen(),
        ChatScreen.routeName: (context) => ChatScreen(),
        ReviewScreen.routeName: (context) => ReviewScreen(),
        AllReviewScreen.routeName: (context) => AllReviewScreen(),
      },
    );
  }
}
