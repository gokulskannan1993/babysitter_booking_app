import 'package:babysitter_booking_app/models/jobs_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';

class Parent extends UserModel {
  List<Job> jobs;

  Parent() : super() {
    this.jobs = [];
  }
}
