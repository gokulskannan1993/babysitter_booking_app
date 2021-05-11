import 'package:flutter/material.dart';

//Buttons in the welcome, login and registration screen and many other screens
class CustomIconButton extends StatelessWidget {
  final Color backgroundColor;
  final Function onPressed; //event handler function
  final double minWidth;
  final Icon icon;
  //constructor
  CustomIconButton(
      {@required this.backgroundColor,
      @required this.icon,
      this.onPressed,
      this.minWidth = 200});

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
            minWidth: minWidth,
            height: 42.0,
            child: icon),
      ),
    );
  }
}
