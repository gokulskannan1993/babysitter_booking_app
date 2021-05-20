import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/job_detail_screen.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/add_job_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "home_screen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String state = 'default', homestate = "default";

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

  Future<String> createMessageInput(BuildContext context) {
    String message = "Hi I would like to apply for this job";
    TextEditingController tController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Your Message ?"),
            content: TextField(
              controller: tController,
            ),
            actions: [
              CustomLargeButton(
                textColor: kPrimaryColor,
                backgroundColor: kSecondaryColor,
                btnText: "Apply",
                minWidth: 100,
                onPressed: () {
                  setState(() {
                    state = "browse";
                  });
                  Navigator.pop(
                      context,
                      tController.text.toString() == ""
                          ? message
                          : tController.text.toString());
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    CalendarController _controller = CalendarController();

    return Scaffold(
        body: FutureBuilder(
            future: _firestore.collection("users").doc(loggedInUser.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // if the snapshot is loading
                return Text("Loading...");
              } else {
                //Mapping all the fields
                Map<String, dynamic> currentUser = snapshot.data.data();

                return SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(30),
                          height: 75.0,
                          child: Card(
                            // for the main menu tab
                            elevation: 20,
                            shadowColor: kSecondaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomIconButton(
                                  icon: Icon(
                                    Icons.account_circle,
                                    color: kSecondaryColor,
                                  ),
                                  minWidth: 50,
                                  backgroundColor: kPrimaryColor,
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pushNamed(
                                          context, ProfileScreen.routeName,
                                          arguments: {
                                            "user": loggedInUser.uid
                                          });
                                    });
                                  },
                                ),
                                CustomLargeButton(
                                  minWidth: 100,
                                  backgroundColor: state == "default"
                                      ? kSecondaryColor
                                      : kPrimaryColor,
                                  textColor: state == "default"
                                      ? kPrimaryColor
                                      : kSecondaryColor,
                                  btnText: "Home",
                                  onPressed: () {
                                    setState(() {
                                      state = 'default';
                                    });
                                  },
                                ),
                                if (currentUser["role"] == "Babysitter")
                                  CustomLargeButton(
                                    minWidth: 100,
                                    backgroundColor: state == "browse"
                                        ? kSecondaryColor
                                        : kPrimaryColor,
                                    textColor: state == "browse"
                                        ? kPrimaryColor
                                        : kSecondaryColor,
                                    btnText: "Browse",
                                    onPressed: () {
                                      setState(() {
                                        state = 'browse';
                                      });
                                    },
                                  ),
                                CustomIconButton(
                                  icon: Icon(
                                    Icons.message,
                                    color: state == "message"
                                        ? kPrimaryColor
                                        : kSecondaryColor,
                                  ),
                                  minWidth: 50,
                                  backgroundColor: state == "message"
                                      ? kSecondaryColor
                                      : kPrimaryColor,
                                  onPressed: () {
                                    setState(() {
                                      state = 'message';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state == "default" &&
                            currentUser["role"] == "Babysitter")
                          Column(
                            children: [
                              Card(
                                elevation: 12,
                                shadowColor: kSecondaryColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CustomLargeButton(
                                      textColor: homestate == "default"
                                          ? kPrimaryColor
                                          : kSecondaryColor,
                                      backgroundColor: homestate == "default"
                                          ? kSecondaryColor
                                          : kPrimaryColor,
                                      btnText: "Calender",
                                      minWidth: 100,
                                      onPressed: () {
                                        setState(() {
                                          homestate = "default";
                                        });
                                      },
                                    ),
                                    CustomLargeButton(
                                      textColor: homestate == "offered"
                                          ? kPrimaryColor
                                          : kSecondaryColor,
                                      backgroundColor: homestate == "offered"
                                          ? kSecondaryColor
                                          : kPrimaryColor,
                                      btnText: "Offered",
                                      minWidth: 100,
                                      onPressed: () {
                                        setState(() {
                                          homestate = "offered";
                                        });
                                      },
                                    ),
                                    CustomLargeButton(
                                      textColor: homestate == "applied"
                                          ? kPrimaryColor
                                          : kSecondaryColor,
                                      backgroundColor: homestate == "applied"
                                          ? kSecondaryColor
                                          : kPrimaryColor,
                                      btnText: "Applied Jobs",
                                      minWidth: 100,
                                      onPressed: () {
                                        setState(() {
                                          homestate = "applied";
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (homestate == "default")
                                Column(
                                  children: [
                                    CalenderForBabySitter(
                                        controller: _controller),
                                  ],
                                )
                              else if (homestate == "offered")
                                Column(
                                  children: [
                                    if (List.from(currentUser["offeredJobs"])
                                        .isEmpty)
                                      Text(
                                        "No Jobs Offered",
                                        style:
                                            TextStyle(color: kSecondaryColor),
                                      )
                                    else
                                      for (var jobId
                                          in currentUser["offeredJobs"])
                                        FutureBuilder(
                                            future: _firestore
                                                .collection("jobs")
                                                .doc(jobId)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // if the snapshot is loading
                                                  return Text("Loading...");
                                                } else {
                                                  Map<String, dynamic> job =
                                                      snapshot.data.data();

                                                  return Card(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color:
                                                                  kSecondaryColor)),
                                                      child: Column(
                                                        children: [
                                                          FutureBuilder(
                                                            future: _firestore
                                                                .collection(
                                                                    "users")
                                                                .doc(job[
                                                                    "creator"])
                                                                .get(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Text(
                                                                    "Loading...");
                                                              } else {
                                                                Map<String,
                                                                        dynamic>
                                                                    userData =
                                                                    snapshot
                                                                        .data
                                                                        .data();
                                                                return Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              20),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pushNamed(
                                                                          context,
                                                                          UserScreen
                                                                              .routeName,
                                                                          arguments: {
                                                                            "userid":
                                                                                snapshot.data.id,
                                                                          });
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        CircleAvatar(
                                                                          radius:
                                                                              30,
                                                                          backgroundImage:
                                                                              NetworkImage(userData["imageUrl"]),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          children: [
                                                                            Text(
                                                                              "${userData["name"]}",
                                                                              style: TextStyle(fontSize: 15),
                                                                            ),
                                                                            Text(
                                                                              "Created by",
                                                                              style: TextStyle(fontSize: 10),
                                                                            ),
                                                                          ],
                                                                        ),
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
                                                              style: TextStyle(
                                                                  color:
                                                                      kSecondaryColor),
                                                            ),
                                                            subtitle: Text(
                                                              "From ${job["from"]} to ${job["to"]}",
                                                              style: TextStyle(
                                                                  color:
                                                                      kSecondaryColor),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              CustomLargeButton(
                                                                textColor:
                                                                    kSecondaryColor,
                                                                backgroundColor:
                                                                    kPrimaryColor,
                                                                btnText:
                                                                    "Accept",
                                                                minWidth: 150,
                                                                onPressed: () {
                                                                  _firestore
                                                                      .collection(
                                                                          "jobs")
                                                                      .doc(
                                                                          jobId)
                                                                      .update({
                                                                    "assignedTo":
                                                                        loggedInUser
                                                                            .uid,
                                                                    "askedTo":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      loggedInUser
                                                                          .uid
                                                                    ])
                                                                  });
                                                                  _firestore
                                                                      .collection(
                                                                          "users")
                                                                      .doc(loggedInUser
                                                                          .uid)
                                                                      .update({
                                                                    "assignedJobs":
                                                                        FieldValue
                                                                            .arrayUnion([
                                                                      jobId
                                                                    ]),
                                                                    "offeredJobs":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      jobId
                                                                    ])
                                                                  });

                                                                  setState(() {
                                                                    homestate =
                                                                        "offered";
                                                                  });
                                                                },
                                                              ),
                                                              CustomLargeButton(
                                                                textColor:
                                                                    kPrimaryColor,
                                                                backgroundColor:
                                                                    kSecondaryColor,
                                                                btnText:
                                                                    "Reject",
                                                                minWidth: 150,
                                                                onPressed: () {
                                                                  _firestore
                                                                      .collection(
                                                                          "jobs")
                                                                      .doc(
                                                                          jobId)
                                                                      .update({
                                                                    "askedTo":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      loggedInUser
                                                                          .uid
                                                                    ])
                                                                  });
                                                                  _firestore
                                                                      .collection(
                                                                          "users")
                                                                      .doc(loggedInUser
                                                                          .uid)
                                                                      .update({
                                                                    "offeredJobs":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      jobId
                                                                    ])
                                                                  });
                                                                  setState(() {
                                                                    homestate =
                                                                        "offered";
                                                                  });
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                return Container();
                                              }
                                            })
                                  ],
                                )
                              else if (homestate == "applied")
                                Column(
                                  children: [
                                    if (List.from(currentUser["appliedJobs"])
                                        .isNotEmpty)
                                      for (var jobId
                                          in currentUser["appliedJobs"])
                                        FutureBuilder(
                                            future: _firestore
                                                .collection("jobs")
                                                .doc(jobId)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // if the snapshot is loading
                                                  return Text("Loading...");
                                                } else {
                                                  Map<String, dynamic> job =
                                                      snapshot.data.data();

                                                  return Card(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color:
                                                                  kSecondaryColor)),
                                                      child: Column(
                                                        children: [
                                                          FutureBuilder(
                                                            future: _firestore
                                                                .collection(
                                                                    "users")
                                                                .doc(job[
                                                                    "creator"])
                                                                .get(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Text(
                                                                    "Loading...");
                                                              } else {
                                                                Map<String,
                                                                        dynamic>
                                                                    userData =
                                                                    snapshot
                                                                        .data
                                                                        .data();
                                                                return Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              20),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pushNamed(
                                                                          context,
                                                                          UserScreen
                                                                              .routeName,
                                                                          arguments: {
                                                                            "userid":
                                                                                snapshot.data.id,
                                                                          });
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        CircleAvatar(
                                                                          radius:
                                                                              30,
                                                                          backgroundImage:
                                                                              NetworkImage(userData["imageUrl"]),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          children: [
                                                                            Text(
                                                                              "${userData["name"]}",
                                                                              style: TextStyle(fontSize: 15),
                                                                            ),
                                                                            Text(
                                                                              "Created by",
                                                                              style: TextStyle(fontSize: 10),
                                                                            ),
                                                                          ],
                                                                        ),
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
                                                              style: TextStyle(
                                                                  color:
                                                                      kSecondaryColor),
                                                            ),
                                                            subtitle: Text(
                                                              "From ${job["from"]} to ${job["to"]}",
                                                              style: TextStyle(
                                                                  color:
                                                                      kSecondaryColor),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              CustomLargeButton(
                                                                textColor:
                                                                    kPrimaryColor,
                                                                backgroundColor:
                                                                    kSecondaryColor,
                                                                btnText:
                                                                    "Delete",
                                                                minWidth: 150,
                                                                onPressed: () {
                                                                  List
                                                                      appliedJobs =
                                                                      List.from(
                                                                          currentUser[
                                                                              "appliedJobs"]);
                                                                  List askedBy =
                                                                      List.from(
                                                                          job["askedBy"]);

                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          askedBy
                                                                              .length;
                                                                      i++) {
                                                                    if (askedBy[i]
                                                                            [
                                                                            "user"] ==
                                                                        loggedInUser
                                                                            .uid) {
                                                                      askedBy
                                                                          .removeAt(
                                                                              i);
                                                                    }
                                                                  }
                                                                  appliedJobs
                                                                      .remove(
                                                                          jobId);
                                                                  _firestore
                                                                      .collection(
                                                                          "jobs")
                                                                      .doc(
                                                                          jobId)
                                                                      .update({
                                                                    "askedBy":
                                                                        askedBy
                                                                  });
                                                                  _firestore
                                                                      .collection(
                                                                          "users")
                                                                      .doc(loggedInUser
                                                                          .uid)
                                                                      .update({
                                                                    "appliedJobs":
                                                                        appliedJobs
                                                                  });
                                                                  setState(() {
                                                                    homestate =
                                                                        "applied";
                                                                  });
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                return Container();
                                              }
                                            })
                                    else
                                      Text(
                                        "No Jobs Applied",
                                        style:
                                            TextStyle(color: kSecondaryColor),
                                      )
                                  ],
                                )
                            ],
                          )
                        else if (state == "default" &&
                            currentUser["role"] == "Parent")
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  child: CustomLargeButton(
                                    backgroundColor: kSecondaryColor,
                                    textColor: kPrimaryColor,
                                    btnText: "+ Create Job",
                                    minWidth: 150,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AddJobScreen.routeName);
                                    },
                                  ),
                                ),
                                CardForJobsParent(
                                    firestore: _firestore,
                                    loggedInUser: loggedInUser),
                              ],
                            ),
                          )
                        else if (state == "browse")
                          Container(
                            child: Card(
                              child: StreamBuilder(
                                stream: _firestore
                                    .collection("jobs")
                                    .where("assignedTo", isEqualTo: "")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Card> joblist = [];
                                    final jobs = snapshot.data.docs;
                                    for (var job in jobs) {
                                      bool isAlright = true;
                                      List jobsApplied =
                                          List.from(job.data()["askedBy"]);
                                      List userApplied =
                                          List.from(currentUser["appliedJobs"]);

                                      for (var child in job["children"]) {
                                        if (child["age"] <
                                                currentUser["minAgeofChild"] ||
                                            child["age"] >
                                                currentUser["maxAgeofChild"]) {
                                          isAlright = false;
                                        }
                                      }

                                      if (!userApplied.contains(job.id) &&
                                          currentUser["maxNoofChildren"] >=
                                              List.from(job["children"])
                                                  .length &&
                                          isAlright) {
                                        final jobCard = Card(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color:
                                                            kSecondaryColor)),
                                                child: Column(children: [
                                                  FutureBuilder(
                                                    future: _firestore
                                                        .collection("users")
                                                        .doc(job
                                                            .data()["creator"])
                                                        .get(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Text(
                                                            "Loading...");
                                                      } else {
                                                        Map<String, dynamic>
                                                            userData = snapshot
                                                                .data
                                                                .data();

                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  UserScreen
                                                                      .routeName,
                                                                  arguments: {
                                                                    "userid":
                                                                        snapshot
                                                                            .data
                                                                            .id,
                                                                  });
                                                            },
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    CircleAvatar(
                                                                      radius:
                                                                          30,
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                              userData["imageUrl"]),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          "${userData["name"]}",
                                                                          style:
                                                                              TextStyle(fontSize: 15),
                                                                        ),
                                                                        Text(
                                                                          "Created by",
                                                                          style:
                                                                              TextStyle(fontSize: 10),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    CustomLargeButton(
                                                                      textColor:
                                                                          kPrimaryColor,
                                                                      backgroundColor:
                                                                          kSecondaryColor,
                                                                      btnText:
                                                                          "Apply",
                                                                      minWidth:
                                                                          100,
                                                                      onPressed:
                                                                          () {
                                                                        createMessageInput(context).then((value) =>
                                                                            {
                                                                              jobsApplied.insert(0, {
                                                                                "user": loggedInUser.uid,
                                                                                "message": value
                                                                              }),
                                                                              userApplied.insert(0, job.id),
                                                                              _firestore.collection("users").doc(loggedInUser.uid).update({
                                                                                "appliedJobs": userApplied
                                                                              }),
                                                                              _firestore.collection("jobs").doc(job.id).update({
                                                                                "askedBy": jobsApplied
                                                                              }),
                                                                            });
                                                                        joblist
                                                                            .removeAt(0);
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                                ListTile(
                                                                  title: Text(
                                                                    "Number of Children: ${List.from(userData["children"]).length.toString()}",
                                                                    style: TextStyle(
                                                                        color:
                                                                            kSecondaryColor),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  title: Text(
                                                                    job.data()[
                                                                        "date"],
                                                                    style: TextStyle(
                                                                        color:
                                                                            kSecondaryColor),
                                                                  ),
                                                                  subtitle:
                                                                      Text(
                                                                    "From ${job.data()["from"]} to ${job.data()["to"]}",
                                                                    style: TextStyle(
                                                                        color:
                                                                            kSecondaryColor),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ])));
                                        joblist.insert(0, jobCard);
                                      }
                                    }

                                    return Container(
                                      child: Column(
                                        children: joblist,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      "No Jobs Posted",
                                      style: TextStyle(color: kSecondaryColor),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            }));
  }
}

// card for jobs for the home page for parents
class CardForJobsParent extends StatelessWidget {
  const CardForJobsParent({
    Key key,
    @required FirebaseFirestore firestore,
    @required this.loggedInUser,
  })  : _firestore = firestore,
        super(key: key);

  final FirebaseFirestore _firestore;
  final User loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("jobs")
            .where("creator", isEqualTo: loggedInUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Card> joblist = [];
            final jobs = snapshot.data.docs;
            for (var job in jobs) {
              final jobCard = Card(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kSecondaryColor)),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          job.data()["date"],
                          style: TextStyle(color: kSecondaryColor),
                        ),
                        subtitle: Text(
                          "From ${job.data()["from"]} to ${job.data()["to"]}",
                          style: TextStyle(color: kSecondaryColor),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomLargeButton(
                            textColor: kPrimaryColor,
                            backgroundColor: kSecondaryColor,
                            btnText: "More Info",
                            minWidth: 150,
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, JobDetailScreen.routeName,
                                  arguments: {"job": job.id});
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
              joblist.add(jobCard);
            }
            return Container(
              child: Column(
                children: joblist,
              ),
            );
          } else {
            return Container(
              child: Text(
                "No Jobs Created",
                style: TextStyle(color: kSecondaryColor, fontSize: 30),
              ),
            );
          }
        },
      ),
    );
  }
}

// Calender view for Babysitter
class CalenderForBabySitter extends StatelessWidget {
  const CalenderForBabySitter({
    Key key,
    @required CalendarController controller,
  })  : _controller = controller,
        super(key: key);

  final CalendarController _controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TableCalendar(
        onDaySelected: (day, events, holidays) {},
        initialCalendarFormat: CalendarFormat.twoWeeks,
        calendarController: _controller,
        calendarStyle: CalendarStyle(
            todayColor: kMediumDarkText, selectedColor: kSecondaryColor),
        headerStyle: HeaderStyle(
            centerHeaderTitle: true,
            formatButtonTextStyle: TextStyle(color: kPrimaryColor),
            formatButtonDecoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
}
