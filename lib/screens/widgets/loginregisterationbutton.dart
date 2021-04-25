import 'package:flutter/material.dart';

//Buttons in the welcome, login and registration screen
class LoginRegisterButton extends StatelessWidget {
  final Color textColor, backgroundColor;
  final String btnText, targetScreen;

  //constructor
  LoginRegisterButton(
      {@required this.textColor,
      @required this.backgroundColor,
      @required this.btnText,
      this.targetScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: () {
            //Go to login screen.
            Navigator.pushNamed(context, targetScreen);
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            btnText,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
