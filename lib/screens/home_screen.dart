import 'package:babysitter_booking_app/models/babysitter_model.dart';
import 'package:babysitter_booking_app/models/parent_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/user_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/add_job_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/jobs_model.dart';
import 'package:intl/intl.dart';
import 'package:babysitter_booking_app/screens/select_babysitter_screen.dart';

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
  String state = 'default',
      dateString = "Select Date",
      timeFrom = "Time From",
      timeTo = "Time To";
  UserModel user;

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
                Map<String, dynamic> userData = snapshot.data.data();
                if (userData["role"] == "Babysitter") {
                  user = Babysitter();
                } else {
                  user = Parent();
                }
                user.id = loggedInUser.uid;
                user.name = userData["name"];
                user.email = userData["email"];
                user.street = userData["street"];
                user.county = userData["county"];
                user.about = userData["about"];
                user.phone = userData["phone"];
                user.followers = userData["followers"];
                user.recommends = userData["recommends"];
                user.rating = userData["rating"];
                user.profileImage = userData["imageUrl"];
                return SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(30),
                          height: 75.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CustomLargeButton(
                                minWidth: 100,
                                btnText: "Profile",
                                onPressed: () {
                                  setState(() {
                                    Navigator.pushNamed(
                                        context, ProfileScreen.routeName,
                                        arguments: {"user": user});
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
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
                              SizedBox(
                                width: 20,
                              ),
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
                              SizedBox(
                                width: 20,
                              ),
                              CustomLargeButton(
                                minWidth: 100,
                                backgroundColor: state == "message"
                                    ? kSecondaryColor
                                    : kPrimaryColor,
                                textColor: state == "message"
                                    ? kPrimaryColor
                                    : kSecondaryColor,
                                btnText: "Messages",
                                onPressed: () {
                                  setState(() {
                                    state = 'message';
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (state == "default" && user is Babysitter)
                          Column(
                            children: [
                              CalenderForBabySitter(controller: _controller),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          )
                        else if (state == "default" && user is Parent)
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
                                CardForJobs(firestore: _firestore, user: user),
                              ],
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

// card for jobs
class CardForJobs extends StatelessWidget {
  const CardForJobs({
    Key key,
    @required FirebaseFirestore firestore,
    @required this.user,
  })  : _firestore = firestore,
        super(key: key);

  final FirebaseFirestore _firestore;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("jobs")
            .where("creator ==" + user.id)
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
                      FutureBuilder(
                        future: _firestore
                            .collection("users")
                            .doc(job.data()["creator"])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          NetworkImage(userData["imageUrl"]),
                                    ),
                                    SizedBox(
                                      width: 10,
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
                      if (job.data()["assignedTo"] != "")
                        FutureBuilder(
                          future: _firestore
                              .collection("users")
                              .doc(job.data()["assignedTo"])
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
                      if (job.data()["askedTo"] != "")
                        FutureBuilder(
                          future: _firestore
                              .collection("users")
                              .doc(job.data()["askedTo"])
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
                      if (job.data()["askedBy"] != "")
                        FutureBuilder(
                          future: _firestore
                              .collection("users")
                              .doc(job.data()["askedBy"])
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
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
                                      Column(
                                        children: [
                                          Text(
                                            "${userData["name"]}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          Text(
                                            "Status: Waiting for your Approval",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
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
                                                .doc(job.id)
                                                .update({
                                              "assignedTo":
                                                  job.data()["askedBy"],
                                              "askedBy": "",
                                            });
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
                                                .doc(job.id)
                                                .update({
                                              "askedBy": "",
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
                          if (job.data()["assignedTo"] == "")
                            CustomLargeButton(
                              textColor: kSecondaryColor,
                              backgroundColor: kPrimaryColor,
                              btnText: job.data()["askedTo"] == ""
                                  ? "Add Babysitter"
                                  : "Change Babysitter",
                              minWidth: 150,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, SelectBabysitter.routeName,
                                    arguments: {
                                      "jobID": job.id,
                                      "maxWage": job.data()["maxWage"]
                                    });
                              },
                            ),
                          CustomLargeButton(
                            textColor: kPrimaryColor,
                            backgroundColor: kSecondaryColor,
                            btnText: "Delete",
                            minWidth: 150,
                            onPressed: () {
                              _firestore
                                  .collection("jobs")
                                  .doc(job.id)
                                  .delete();
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
