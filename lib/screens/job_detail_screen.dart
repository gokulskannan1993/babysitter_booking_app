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
      body: SingleChildScrollView(
        child: FutureBuilder(
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

              DateTime jobStart = DateFormat("d MMMM, yyyy, hh:mm a")
                  .parse("${job["date"]}, ${job["from"]}");

              DateTime currentTime = DateTime.now();

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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (currentTime.isAfter(jobEnd))
                                        CustomLargeButton(
                                          textColor: kSecondaryColor,
                                          backgroundColor: kPrimaryColor,
                                          btnText: "Give Feedback",
                                          minWidth: 80,
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, ReviewScreen.routeName,
                                                arguments: {
                                                  'userid': job["assignedTo"]
                                                });
                                          },
                                        ),
                                      SizedBox(
                                        width: 50,
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
                        for (int i = 0;
                            i < List.from(job["askedTo"]).length;
                            i++)
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
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
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
                                                "askedTo":
                                                    FieldValue.arrayRemove(
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
                                          width: 10,
                                        ),
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                              userData["imageUrl"]),
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
                        for (var user in job["askedBy"])
                          FutureBuilder(
                            future:
                                _firestore.collection("users").doc(user).get(),
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
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 10,
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
                                          width: 10,
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
                                                "assignedTo": user,
                                                "askedBy": [],
                                                "askedTo": []
                                              });
                                              _firestore
                                                  .collection("users")
                                                  .doc(user)
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
                                              _firestore
                                                  .collection("jobs")
                                                  .doc(data["job"])
                                                  .update({
                                                "askedBy":
                                                    FieldValue.arrayRemove(
                                                        [user]),
                                              });

                                              _firestore
                                                  .collection("users")
                                                  .doc(user)
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
                                                  arguments: {'userid': user});
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
                          "Maximum Wage Possible: ${job["maxWage"]}",
                          style: TextStyle(color: kSecondaryColor),
                        ),
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
                          if (job["assignedTo"] == "" &&
                              !currentTime.isAfter(jobStart))
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
                                      "askedUsers": job["askedTo"],
                                      "askedBy": job["askedBy"],
                                    }).then((value) => {
                                      setState(() {
                                        // refresh state of Page1
                                      })
                                    });
                              },
                            ),
                          if (job["assignedTo"] == "")
                            CustomLargeButton(
                              textColor: kSecondaryColor,
                              backgroundColor: kPrimaryColor,
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
      ),
    );
  }
}
