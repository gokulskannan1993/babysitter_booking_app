import 'package:babysitter_booking_app/models/jobs_model.dart';
import 'package:babysitter_booking_app/screens/welcome_screen.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_button.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class AddJobScreen extends StatefulWidget {
  static String routeName = "add_job_screen";
  @override
  _AddJobState createState() => _AddJobState();
}

class _AddJobState extends State<AddJobScreen> {
  //instance of firestore
  final _firestore = FirebaseFirestore.instance;
  //fire auth instance
  final _auth = FirebaseAuth.instance;

  User loggedInUser;

  String dateString = "Select Date",
      timeFrom = "Select time from",
      timeTo = "Select time To";
  int maxWage = 10;

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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              ListTile(
                title: Text(
                  "Create a Job",
                  style: TextStyle(color: kSecondaryColor, fontSize: 30),
                ),
              ),
              ListTile(
                  title: Text(
                    dateString,
                    style: TextStyle(color: kSecondaryColor),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  subtitle: Text(
                    "On",
                    style: TextStyle(color: kSecondaryColor),
                  ),
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2022))
                        .then((date) {
                      setState(() {
                        final DateFormat formatter = DateFormat('d MMMM, yyyy');
                        dateString = formatter.format(date);
                      });
                    });
                  }),
              ListTile(
                  title: Text(
                    timeFrom,
                    style: TextStyle(color: kSecondaryColor),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  subtitle: Text(
                    "From",
                    style: TextStyle(color: kSecondaryColor),
                  ),
                  onTap: () {
                    showTimePicker(
                            context: context, initialTime: TimeOfDay.now())
                        .then((value) => {
                              setState(() {
                                timeFrom = value.format(context);
                              })
                            });
                  }),
              ListTile(
                  title: Text(
                    timeTo,
                    style: TextStyle(color: kSecondaryColor),
                  ),
                  subtitle: Text(
                    "To",
                    style: TextStyle(color: kSecondaryColor),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () {
                    showTimePicker(
                            context: context, initialTime: TimeOfDay.now())
                        .then((value) => {
                              setState(() {
                                timeTo = value.format(context);
                              })
                            });
                  }),
              ListTile(
                title: Text(
                  "Select Maximum wage per hour (£)",
                  style: TextStyle(color: kSecondaryColor, fontSize: 20),
                ),
              ),
              NumberPicker(
                  axis: Axis.horizontal,
                  minValue: 10,
                  maxValue: 100,
                  value: maxWage,
                  onChanged: (value) {
                    setState(() {
                      maxWage = value;
                    });
                  }),
              SizedBox(
                height: 30,
              ),
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
                  newJob.creator = loggedInUser.uid;
                  newJob.from = timeFrom;
                  newJob.to = timeTo;
                  newJob.maxWage = maxWage;

                  _firestore.collection("jobs").add({
                    "date": newJob.date,
                    "creator": newJob.creator,
                    "from": newJob.from,
                    "to": newJob.to,
                    "assignedTo": newJob.assignedTo,
                    "status": newJob.status,
                    "maxWage": newJob.maxWage,
                    "askedTo": [],
                    "askedBy": [],
                  });
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
