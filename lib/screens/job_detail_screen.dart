import 'package:babysitter_booking_app/screens/chat_screen.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/home_screen.dart';
import 'package:babysitter_booking_app/screens/review_screen.dart';
import 'package:babysitter_booking_app/screens/select_babysitter_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_icon_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobDetailScreen extends StatefulWidget {
  static String routeName = "job_detail_screen";
  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map data = {};

  bool askedByView = false;
  bool askedToView = false;
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;

  //fire auth instance
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //checks for logged in user
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      } else {
        Navigator.pushNamed(context, WelcomeScreen.routeName);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          color: kSecondaryColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _firestore.collection("jobs").doc(data["job"]).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // if the snapshot is loading
            return Text("Loading...");
          } else {
            Map<String, dynamic> job = snapshot.data.data();

            String dateandTime = "${job["date"]}, ${job["to"]}";
            DateTime jobEnd =
                DateFormat("d MMMM, yyyy, hh:mm a").parse(dateandTime);

            DateTime currentTime = DateTime.now();

            print(jobEnd.isAfter(currentTime));

            return Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (job["assignedTo"] != "")
                      FutureBuilder(
                        future: _firestore
                            .collection("users")
                            .doc(job["assignedTo"])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // if the snapshot is loading
                            return Text("Loading...");
                          } else {
                            Map<String, dynamic> userData =
                                snapshot.data.data();
                            return Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, UserScreen.routeName,
                                      arguments: {
                                        "userid": snapshot.data.id,
                                      });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (currentTime.isAfter(jobEnd))
                                      CustomLargeButton(
                                        textColor: kSecondaryColor,
                                        backgroundColor: kPrimaryColor,
                                        btnText: "Give Feedback",
                                        minWidth: 100,
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, ReviewScreen.routeName,
                                              arguments: {
                                                'userid': job["assignedTo"]
                                              });
                                        },
                                      ),
                                    SizedBox(
                                      width: 70,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "${userData["name"]}",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          "Assigned to",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          NetworkImage(userData["imageUrl"]),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    if (List.from(job["askedTo"]).isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            askedToView = askedToView ? false : true;
                          });
                        },
                        child: ListTile(
                          title: Text(
                              "Asked To (${List.from(job["askedTo"]).length})"),
                          trailing: askedToView
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    if (askedToView)
                      for (int i = 0; i < List.from(job["askedTo"]).length; i++)
                        FutureBuilder(
                          future: _firestore
                              .collection("users")
                              .doc(List.from(job["askedTo"])[i])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // if the snapshot is loading
                              return Text("Loading...");
                            } else {
                              Map<String, dynamic> userData =
                                  snapshot.data.data();
                              return Container(
                                padding: EdgeInsets.all(20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, UserScreen.routeName,
                                        arguments: {
                                          "userid": snapshot.data.id,
                                          "name": userData["name"],
                                          "about": userData["about"],
                                          "county": userData["county"],
                                          "rating": userData["rating"],
                                          "followers": userData["followers"],
                                          "recommends": userData["recommends"],
                                          "imageUrl": userData["imageUrl"],
                                          "role": userData["role"]
                                        });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _firestore
                                                .collection("jobs")
                                                .doc(data["job"])
                                                .update({
                                              "askedTo": FieldValue.arrayRemove(
                                                  [snapshot.data.id])
                                            });
                                            _firestore
                                                .collection("users")
                                                .doc(snapshot.data.id)
                                                .update({
                                              "offeredJobs":
                                                  FieldValue.arrayRemove(
                                                      [data["job"]])
                                            });
                                            setState(() {});
                                          }),
                                      Column(
                                        children: [
                                          Text(
                                            "${userData["name"]}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          Text(
                                            "Status: Waiting for Babysitter to Accept",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            NetworkImage(userData["imageUrl"]),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    if (List.from(job["askedBy"]).isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            askedByView = askedByView ? false : true;
                          });
                        },
                        child: ListTile(
                          title: Text(
                              "Asked By (${List.from(job["askedBy"]).length})"),
                          trailing: askedByView
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    if (askedByView)
                      for (int i = 0; i < List.from(job["askedBy"]).length; i++)
                        FutureBuilder(
                          future: _firestore
                              .collection("users")
                              .doc(List.from(job["askedBy"])[i]["user"])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // if the snapshot is loading
                              return Text("Loading...");
                            } else {
                              Map<String, dynamic> userData =
                                  snapshot.data.data();
                              String askedByText =
                                  List.from(job["askedBy"])[i]["message"];
                              try {
                                askedByText = askedByText.substring(0, 10);
                              } catch (e) {}
                              return Container(
                                padding: EdgeInsets.all(20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, UserScreen.routeName,
                                        arguments: {
                                          "userid": snapshot.data.id,
                                        });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                userData["imageUrl"]),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${userData["name"]}",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "$askedByText...",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.done,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            _firestore
                                                .collection("jobs")
                                                .doc(data["job"])
                                                .update({
                                              "assignedTo":
                                                  List.from(job["askedBy"])[i]
                                                      ["user"],
                                              "askedBy": [],
                                              "askedTo": []
                                            });
                                            _firestore
                                                .collection("users")
                                                .doc(
                                                    List.from(job["askedBy"])[i]
                                                        ["user"])
                                                .update({
                                              "appliedJobs":
                                                  FieldValue.arrayRemove(
                                                      [data["job"]]),
                                              "assignedJobs":
                                                  FieldValue.arrayUnion(
                                                      [data["job"]]),
                                            });
                                            setState(() {});
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            List askedBy =
                                                List.from(job["askedBy"]);
                                            askedBy.removeAt(i);
                                            _firestore
                                                .collection("jobs")
                                                .doc(data["job"])
                                                .update({
                                              "askedBy": askedBy,
                                            });

                                            _firestore
                                                .collection("users")
                                                .doc(
                                                    List.from(job["askedBy"])[i]
                                                        ["user"])
                                                .update({
                                              "appliedJobs":
                                                  FieldValue.arrayRemove(
                                                      [data["job"]]),
                                            });
                                            setState(() {});
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.message,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, ChatScreen.routeName,
                                                arguments: {
                                                  'userid': List.from(
                                                      job["askedBy"])[i]["user"]
                                                });
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    ListTile(
                      title: Text(
                        job["date"],
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      subtitle: Text(
                        "From ${job["from"]} to ${job["to"]}",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (job["assignedTo"] == "")
                          CustomLargeButton(
                            textColor: kSecondaryColor,
                            backgroundColor: kPrimaryColor,
                            btnText: "Find Babysitter",
                            minWidth: 150,
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, SelectBabysitter.routeName,
                                  arguments: {
                                    "jobID": data["job"],
                                    "maxWage": job["maxWage"],
                                    "askedUsers": job["askedTo"]
                                  });
                            },
                          ),
                        if (job["assignedTo"] == "")
                          CustomLargeButton(
                            textColor: kPrimaryColor,
                            backgroundColor: kSecondaryColor,
                            btnText: "Delete",
                            minWidth: 150,
                            onPressed: () {
                              if (job["assignedTo"] != "") {
                                _firestore
                                    .collection("users")
                                    .doc(job["assignedTo"])
                                    .update({
                                  "assignedJobs":
                                      FieldValue.arrayRemove([data["job"]])
                                });
                              }
                              if (List.from(job["askedTo"]).isNotEmpty) {
                                for (var user in List.from(job["askedTo"])) {
                                  _firestore
                                      .collection("users")
                                      .doc(user)
                                      .update({
                                    "offeredJobs":
                                        FieldValue.arrayRemove([data["job"]])
                                  });
                                }
                              }
                              if (List.from(job["askedBy"]).isNotEmpty) {
                                for (var req in List.from(job["askedBy"])) {
                                  _firestore
                                      .collection("users")
                                      .doc(req["user"])
                                      .update({
                                    "appliedJobs":
                                        FieldValue.arrayRemove([data["job"]])
                                  });
                                }
                              }
                              _firestore
                                  .collection("jobs")
                                  .doc(data["job"])
                                  .delete();
                              Navigator.pushReplacementNamed(
                                  context, HomeScreen.routeName);
                            },
                          )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
