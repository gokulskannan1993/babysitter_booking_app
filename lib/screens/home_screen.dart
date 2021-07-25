import 'package:babysitter_booking_app/screens/chat_screen.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/job_detail_screen.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/add_job_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_icon_button.dart';
import 'package:babysitter_booking_app/services/location_reroute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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

  // to customize the calender with dates have events must be highlighted
  Map<DateTime, List<String>> currentEvents;
  Map unread = {};
  bool newMessage = false;
  final now = DateTime.now();

  DateTime selectedDate = DateTime.now();

  String selectedDateString = DateFormat('d MMMM, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //checks for logged in user
  getCurrentUser() {
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
    CalendarController _controller = CalendarController();

    return Scaffold(
        body: FutureBuilder(
            future: _firestore.collection("users").doc(loggedInUser.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // if the snapshot is loading
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                //Mapping all the fields
                Map<String, dynamic> currentUser = snapshot.data.data();

                return SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        //for the main menu
                        Container(
                          margin: EdgeInsets.all(30),
                          height: 75.0,
                          child: Card(
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
                                StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection('users')
                                      .doc(loggedInUser.uid)
                                      .collection('chats')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: kSecondaryColor,
                                        ),
                                      );
                                    } else {
                                      final chats = snapshot.data.docs;
                                      bool hasUnread = false;
                                      for (var chat in chats) {
                                        hasUnread = chat.data()['unread'];
                                      }

                                      return Stack(
                                        children: [
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
                                                hasUnread = false;
                                              });
                                            },
                                          ),
                                          if (hasUnread)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: CircleAvatar(
                                                radius: 6,
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        //home screen of babysitter
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
                                      btnText: "Calendar",
                                      minWidth: 100,
                                      onPressed: () {
                                        setState(() {
                                          homestate = "default";
                                        });
                                      },
                                    ),
                                    Stack(
                                      children: [
                                        CustomLargeButton(
                                          textColor: homestate == "offered"
                                              ? kPrimaryColor
                                              : kSecondaryColor,
                                          backgroundColor:
                                              homestate == "offered"
                                                  ? kSecondaryColor
                                                  : kPrimaryColor,
                                          btnText: "Offered",
                                          minWidth: 100,
                                          onPressed: () {
                                            _firestore
                                                .collection('users')
                                                .doc(loggedInUser.uid)
                                                .update({"hasNewOffer": false});
                                            setState(() {
                                              homestate = "offered";
                                            });
                                          },
                                        ),
                                        if (currentUser["hasNewOffer"])
                                          Positioned(
                                            top: 10,
                                            right: 5,
                                            child: CircleAvatar(
                                              radius: 6,
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                      ],
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
                                    StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('jobs')
                                            .where('assignedTo',
                                                isEqualTo: loggedInUser.uid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            currentEvents = {};
                                            final jobs = snapshot.data.docs;
                                            for (var job in jobs) {
                                              DateTime date = DateFormat(
                                                      'd MMMM, yyyy', 'en_US')
                                                  .parse(job.data()["date"]);

                                              if (currentEvents[date] == null) {
                                                currentEvents[date] = [];
                                              }
                                              currentEvents[date]
                                                  .add(job.data()["date"]);
                                            }
                                          }
                                          return Card(
                                            // calendar view
                                            child: TableCalendar(
                                              events: currentEvents,
                                              initialSelectedDay: selectedDate,
                                              onDaySelected:
                                                  (day, events, holidays) {
                                                selectedDate = day;
                                                setState(() {
                                                  selectedDateString =
                                                      DateFormat('d MMMM, yyyy')
                                                          .format(day);
                                                });
                                              },
                                              initialCalendarFormat:
                                                  CalendarFormat.week,
                                              calendarController: _controller,
                                              calendarStyle: CalendarStyle(
                                                  todayColor: kMediumDarkText,
                                                  markersPositionTop: 35,
                                                  markersColor: Colors.red,
                                                  selectedColor:
                                                      kSecondaryColor),
                                              headerStyle: HeaderStyle(
                                                centerHeaderTitle: true,
                                                formatButtonVisible: false,
                                              ),
                                            ),
                                          );
                                        }),
                                    for (var jobID
                                        in currentUser["assignedJobs"])
                                      FutureBuilder(
                                        //fetches the job
                                        future: _firestore
                                            .collection('jobs')
                                            .doc(jobID)
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // if the snapshot is loading
                                            return Text("");
                                          } else {
                                            Map<String, dynamic> job =
                                                snapshot.data.data();

                                            if (job['date'] ==
                                                selectedDateString) {
                                              return Card(
                                                elevation: 20,
                                                child: Container(
                                                  padding: EdgeInsets.all(20.0),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color:
                                                              kPrimaryColor)),
                                                  child: FutureBuilder(
                                                    //fetches the creator details
                                                    future: _firestore
                                                        .collection('users')
                                                        .doc(job['creator'])
                                                        .get(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        // if the snapshot is loading
                                                        return Text("");
                                                      } else {
                                                        Map<String, dynamic>
                                                            creator = snapshot
                                                                .data
                                                                .data();

                                                        return Container(
                                                            child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                GestureDetector(
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 20,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            creator["imageUrl"]),
                                                                  ),
                                                                  onTap: () {
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        UserScreen
                                                                            .routeName,
                                                                        arguments: {
                                                                          'userid':
                                                                              job['creator']
                                                                        });
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    Text(
                                                                      creator[
                                                                          "name"],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                    Text(
                                                                      "Created by",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                FutureBuilder(
                                                                    future: _firestore
                                                                        .collection(
                                                                            'users')
                                                                        .doc(loggedInUser
                                                                            .uid)
                                                                        .collection(
                                                                            'chats')
                                                                        .doc(job[
                                                                            'creator'])
                                                                        .get(),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        // if the snapshot is loading
                                                                        return Text(
                                                                            "Loading...");
                                                                      } else {
                                                                        Map<String,
                                                                                dynamic>
                                                                            chatData =
                                                                            snapshot.data.data();
                                                                        if (chatData !=
                                                                            null) {
                                                                          return Stack(
                                                                            children: [
                                                                              IconButton(
                                                                                  icon: Icon(
                                                                                    Icons.message,
                                                                                    color: kSecondaryColor,
                                                                                    size: 25,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.pushNamed(context, ChatScreen.routeName, arguments: {
                                                                                      'userid': job["creator"]
                                                                                    }).then((value) => {
                                                                                          setState(() {
                                                                                            // refresh state of Page1
                                                                                          })
                                                                                        });
                                                                                  }),
                                                                              if (chatData["unread"])
                                                                                Positioned(
                                                                                  top: 5,
                                                                                  right: 5,
                                                                                  child: CircleAvatar(
                                                                                    radius: 6,
                                                                                    backgroundColor: Colors.red,
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          );
                                                                        } else {
                                                                          return IconButton(
                                                                              icon: Icon(
                                                                                Icons.message,
                                                                                color: kSecondaryColor,
                                                                                size: 25,
                                                                              ),
                                                                              onPressed: () {
                                                                                Navigator.pushNamed(context, ChatScreen.routeName, arguments: {
                                                                                  'userid': job["creator"]
                                                                                });
                                                                              });
                                                                        }
                                                                      }
                                                                    }),
                                                                IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      color:
                                                                          kSecondaryColor,
                                                                      size: 30,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      launchLocation(
                                                                          "${creator['street']},  ${creator['county']}");
                                                                    })
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            ListTile(
                                                              title: Text(
                                                                  "From ${job['from']} to ${job['to']}"),
                                                              subtitle: Text(
                                                                  "${creator['street']},  ${creator['county']}"),
                                                            ),
                                                          ],
                                                        ));
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // if there is no jobs for the day
                                              return Text("");
                                            }
                                          }
                                        },
                                      ),
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
                                                                  kPrimaryColor)),
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
                                                              "Wage Per Hour: €${job["maxWage"]}",
                                                              style: TextStyle(
                                                                  color:
                                                                      kSecondaryColor),
                                                            ),
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
                                                                    kSecondaryColor,
                                                                backgroundColor:
                                                                    kPrimaryColor,
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
                                                  return CircularProgressIndicator();
                                                } else {
                                                  Map<String, dynamic> job =
                                                      snapshot.data.data();

                                                  return Card(
                                                    elevation: 10,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color:
                                                                  kPrimaryColor)),
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
                                                                              30,
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
                                                                    "Delete",
                                                                minWidth: 150,
                                                                onPressed: () {
                                                                  _firestore
                                                                      .collection(
                                                                          "jobs")
                                                                      .doc(
                                                                          jobId)
                                                                      .update({
                                                                    "askedBy":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      jobId
                                                                    ])
                                                                  });
                                                                  _firestore
                                                                      .collection(
                                                                          "users")
                                                                      .doc(loggedInUser
                                                                          .uid)
                                                                      .update({
                                                                    "appliedJobs":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      jobId
                                                                    ])
                                                                  });
                                                                  setState(
                                                                      () {});
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

                        //home screen of parent
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

                        //browse jobs
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

                                      // determines if the job is before now
                                      String dateandTime =
                                          "${job["date"]}, ${job["from"]}";
                                      DateTime jobStart =
                                          DateFormat("d MMMM, yyyy, hh:mm a")
                                              .parse(dateandTime);
                                      if (now.isAfter(jobStart) ||
                                          List.from(currentUser["offeredJobs"])
                                              .contains(job.id)) {
                                        isAlright = false;
                                      }

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
                                          isAlright &&
                                          currentUser["wage"] <=
                                              job["maxWage"]) {
                                        final jobCard = Card(
                                            elevation: 10,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: kPrimaryColor)),
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
                                                                          userData[
                                                                              "name"],
                                                                          style:
                                                                              TextStyle(fontSize: 15),
                                                                        ),
                                                                        Text(
                                                                          userData[
                                                                              "county"],
                                                                          style:
                                                                              TextStyle(fontSize: 10),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    CustomLargeButton(
                                                                      textColor:
                                                                          kSecondaryColor,
                                                                      backgroundColor:
                                                                          kPrimaryColor,
                                                                      btnText:
                                                                          "Apply",
                                                                      minWidth:
                                                                          100,
                                                                      onPressed:
                                                                          () {
                                                                        jobsApplied.insert(
                                                                            0,
                                                                            loggedInUser.uid);
                                                                        userApplied.insert(
                                                                            0,
                                                                            job.id);
                                                                        _firestore
                                                                            .collection(
                                                                                "users")
                                                                            .doc(loggedInUser
                                                                                .uid)
                                                                            .update({
                                                                          "appliedJobs":
                                                                              userApplied
                                                                        });
                                                                        _firestore
                                                                            .collection(
                                                                                "jobs")
                                                                            .doc(job
                                                                                .id)
                                                                            .update({
                                                                          "askedBy":
                                                                              jobsApplied
                                                                        });

                                                                        joblist
                                                                            .removeAt(0);
                                                                        setState(
                                                                            () {});
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
                                                                    "Wage Per Hour: €${job.data()["maxWage"]}",
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
                          )

                        //message part
                        else if (state == "message")
                          Container(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('users')
                                  .doc(loggedInUser.uid)
                                  .collection('chats')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  List<GestureDetector> messageCards = [];
                                  final users = snapshot.data.docs.reversed;
                                  for (var user in users) {
                                    final messageCard = GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                                context, ChatScreen.routeName,
                                                arguments: {'userid': user.id})
                                            .then((value) => {
                                                  setState(() {
                                                    // refresh state of Page1
                                                  })
                                                });
                                      },
                                      child: Card(
                                        elevation: 10,
                                        child: FutureBuilder(
                                          future: _firestore
                                              .collection('users')
                                              .doc(user.id)
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              // if the snapshot is loading
                                              return CircularProgressIndicator();
                                            } else {
                                              Map<String, dynamic> messageUser =
                                                  snapshot.data.data();
                                              return FutureBuilder<
                                                      QuerySnapshot>(
                                                  future: _firestore
                                                      .collection("users")
                                                      .doc(loggedInUser.uid)
                                                      .collection("chats")
                                                      .doc(user.id)
                                                      .collection("data")
                                                      .orderBy("time",
                                                          descending: true)
                                                      .get(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      // if the snapshot is loading
                                                      return Text("Loading...");
                                                    } else {
                                                      Map<String, dynamic>
                                                          latestMessage =
                                                          snapshot
                                                              .data.docs.first
                                                              .data();
                                                      String date = DateFormat(
                                                              'dd MMMM, yyyy')
                                                          .format(latestMessage[
                                                                  "time"]
                                                              .toDate());

                                                      String time = DateFormat(
                                                              'hh:mm a')
                                                          .format(latestMessage[
                                                                  "time"]
                                                              .toDate());
                                                      String messageText =
                                                          latestMessage["text"];
                                                      try {
                                                        messageText =
                                                            "${messageText.substring(0, 10)}...";
                                                      } catch (e) {}

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            GestureDetector(
                                                              child:
                                                                  FutureBuilder(
                                                                future: _firestore
                                                                    .collection(
                                                                        'users')
                                                                    .doc(loggedInUser
                                                                        .uid)
                                                                    .collection(
                                                                        'chats')
                                                                    .doc(
                                                                        user.id)
                                                                    .get(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    // if the snapshot is loading
                                                                    return Text(
                                                                        "Loading...");
                                                                  } else {
                                                                    Map<String,
                                                                            dynamic>
                                                                        chatData =
                                                                        snapshot
                                                                            .data
                                                                            .data();

                                                                    _firestore
                                                                        .collection(
                                                                            'users')
                                                                        .doc(user
                                                                            .id)
                                                                        .collection(
                                                                            'chats')
                                                                        .doc(loggedInUser
                                                                            .uid)
                                                                        .collection(
                                                                            'data')
                                                                        .get()
                                                                        .then((QuerySnapshot
                                                                                snapshot) =>
                                                                            {
                                                                              for (var message in snapshot.docs)
                                                                                {
                                                                                  if (message.data()["status"] == "send")
                                                                                    {
                                                                                      _firestore.collection('users').doc(user.id).collection('chats').doc(loggedInUser.uid).collection('data').doc(message.id).update({
                                                                                        'status': "delivered"
                                                                                      })
                                                                                    }
                                                                                }
                                                                            });

                                                                    return Stack(
                                                                        children: [
                                                                          CircleAvatar(
                                                                            radius:
                                                                                30,
                                                                            backgroundImage:
                                                                                NetworkImage(messageUser["imageUrl"]),
                                                                          ),
                                                                          if (chatData[
                                                                              "unread"])
                                                                            Positioned(
                                                                              right: 8,
                                                                              child: CircleAvatar(
                                                                                radius: 6,
                                                                                backgroundColor: Colors.red,
                                                                              ),
                                                                            ),
                                                                        ]);
                                                                  }
                                                                },
                                                              ),
                                                              onTap: () {
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    UserScreen
                                                                        .routeName,
                                                                    arguments: {
                                                                      'userid':
                                                                          user.id
                                                                    });
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  messageUser[
                                                                      "name"],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color:
                                                                          kSecondaryColor),
                                                                ),
                                                                Text(
                                                                  messageText,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color:
                                                                          kMediumDarkText),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  time,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54),
                                                                ),
                                                                Text(
                                                                  date,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Colors
                                                                          .black26),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  });
                                            }
                                          },
                                        ),
                                      ),
                                    );

                                    messageCards.add(messageCard);
                                  }
                                  return Container(
                                    child: Column(
                                      children: messageCards,
                                    ),
                                  );
                                }
                              },
                            ),
                          )
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
              String dateandTime = "${job["date"]}, ${job["to"]}";
              DateTime jobEnd =
                  DateFormat("d MMMM, yyyy, hh:mm a").parse(dateandTime);
              String status =
                  DateTime.now().isAfter(jobEnd) ? "Completed" : "In Progress";
              final jobCard = Card(
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kPrimaryColor)),
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
                      ListTile(
                        title: Text(
                          "Status: $status",
                          style: TextStyle(
                              color: status == "Completed"
                                  ? Colors.red
                                  : Colors.green),
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
