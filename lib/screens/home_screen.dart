import 'package:babysitter_booking_app/models/babysitter_model.dart';
import 'package:babysitter_booking_app/models/parent_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';
import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/profile_screen.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/jobs_model.dart';

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
  List<Job> jobs = [];

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
                user.name = userData["name"];
                user.email = userData["email"];
                user.street = userData["street"];
                user.county = userData["county"];
                user.about = userData["about"];
                user.phone = userData["phone"];
                user.followers = userData["followers"];
                user.recommends = userData["recommends"];
                user.rating = userData["rating"];
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
                              Card(
                                child: TableCalendar(
                                  onDaySelected: (day, events, holidays) {
                                    print(day.toIso8601String());
                                  },
                                  initialCalendarFormat:
                                      CalendarFormat.twoWeeks,
                                  calendarController: _controller,
                                  calendarStyle: CalendarStyle(
                                      todayColor: kMediumDarkText,
                                      selectedColor: kSecondaryColor),
                                  headerStyle: HeaderStyle(
                                      centerHeaderTitle: true,
                                      formatButtonTextStyle:
                                          TextStyle(color: kPrimaryColor),
                                      formatButtonDecoration: BoxDecoration(
                                          color: kSecondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          )
                        else if (state == "default" && user is Parent)
                          Container(
                            child: Card(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Create a Job",
                                      style: TextStyle(
                                          color: kSecondaryColor, fontSize: 20),
                                    ),
                                  ),
                                  ListTile(
                                      title: Text(
                                        dateString,
                                        style:
                                            TextStyle(color: kSecondaryColor),
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                      onTap: () {
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2022))
                                            .then((date) {
                                          setState(() {
                                            dateString =
                                                "${date.day}/${date.month}/${date.year}";
                                          });
                                        });
                                      }),
                                  ListTile(
                                      title: Text(
                                        timeFrom,
                                        style:
                                            TextStyle(color: kSecondaryColor),
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((value) => {
                                                  setState(() {
                                                    timeFrom =
                                                        "${value.hour}:${value.minute}";
                                                  })
                                                });
                                      }),
                                  ListTile(
                                      title: Text(
                                        timeTo,
                                        style:
                                            TextStyle(color: kSecondaryColor),
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((value) => {
                                                  setState(() {
                                                    timeTo =
                                                        "${value.hour}:${value.minute}";
                                                  })
                                                });
                                      }),
                                  FloatingActionButton(
                                    backgroundColor: kSecondaryColor,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      Job newJob = Job();
                                      newJob.date = dateString;
                                      newJob.assignedTo = user.id;
                                      newJob.from = timeFrom;
                                      newJob.to = timeTo;
                                      jobs.add(newJob);
                                    },
                                  ),
                                ],
                              ),
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
