import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  static String routeName = "user_screen";
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map data = {};

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: kSecondaryColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.27,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(data["imageUrl"]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        data["name"],
                        style: TextStyle(fontSize: 16, color: kSecondaryColor),
                      ),
                      Text(
                        data["county"],
                        style: TextStyle(fontSize: 16, color: kMediumDarkText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("User Rating"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(data["rating"]),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Followers"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(data["followers"]),
                    ],
                  ),
                  if (data["role"] == "Babysitter")
                    Column(
                      children: [
                        Text("Favorites"),
                        SizedBox(
                          height: 5,
                        ),
                        Text(data["recommends"]),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomLargeButton(
                  textColor: kPrimaryColor,
                  backgroundColor: kSecondaryColor,
                  btnText: "Add to favorites",
                  minWidth: 150,
                ),
                CustomLargeButton(
                  textColor: kPrimaryColor,
                  backgroundColor: kSecondaryColor,
                  btnText: "Message",
                  minWidth: 150,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kSecondaryColor),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  data["about"],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: kSecondaryColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
