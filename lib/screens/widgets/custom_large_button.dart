import 'package:flutter/material.dart';

//Buttons in the welcome, login and registration screen and many other screens
class CustomLargeButton extends StatelessWidget {
  final Color textColor, backgroundColor;
  final String btnText;
  final Function onPressed; //event handler function
  //constructor
  CustomLargeButton(
      {@required this.textColor,
      @required this.backgroundColor,
      @required this.btnText,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
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
