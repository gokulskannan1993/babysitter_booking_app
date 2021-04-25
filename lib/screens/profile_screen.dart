import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "profile_screen";
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Stack(children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        "https://st3.depositphotos.com/15648834/17930/v/1600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg"),
                  ),
                  Positioned(
                      bottom: 3,
                      right: 2,
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: (Icon(Icons.edit)))),
                ]),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Gokul",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  "Dublin, Ireland",
                  style: TextStyle(fontSize: 16, color: Colors.white60),
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
                    Text("9/10"),
                  ],
                ),
                Column(
                  children: [
                    Text("Followers"),
                    SizedBox(
                      height: 5,
                    ),
                    Text("111"),
                  ],
                ),
                Column(
                  children: [
                    Text("Recommends"),
                    SizedBox(
                      height: 5,
                    ),
                    Text("111"),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          child: Column(
            children: [
              Text("User Information"),
              Divider(),
              ListTile(
                title: Text(
                  "Location",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text("806 Howth Road, Dublin 5"),
                leading: Icon(Icons.location_on),
              ),
              ListTile(
                title: Text(
                  "Email",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text("gokul@example.com"),
                leading: Icon(Icons.email),
              ),
              ListTile(
                title: Text(
                  "Phone",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text("09939384849"),
                leading: Icon(Icons.phone),
              ),
              ListTile(
                title: Text(
                  "About My Child",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text("This is me"),
                leading: Icon(Icons.info),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
