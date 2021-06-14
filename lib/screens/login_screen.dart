import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:babysitter_booking_app/services/validation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _saving = false;
  String email, password;

  var _formKey = GlobalKey<FormState>();

  //instance for firebase auth
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
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
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Email field cannot be empty";
                    } else if (emailAddressValidator(value)) {
                      return "Please Enter a valid email";
                    }
                  },
                  hintText: "Enter your email",
                  inputType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                CustomLargeTextField(
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Password is empty";
                    }
                  },
                  hintText: "Enter your Password",
                  isObscure: true,
                  onChanged: (value) {
                    password = value;
                  },
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
                      if (_formKey.currentState.validate()) {
                        try {
                          //creating the new user at auth
                          final user = await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                          if (user != null) {
                            Navigator.pushNamed(context, HomeScreen.routeName);
                          }
                        } catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Invalid email or password",
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ));
                        }
                      }

                      //for the spinner
                      setState(() {
                        _saving = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
