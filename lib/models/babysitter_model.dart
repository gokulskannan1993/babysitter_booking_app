import 'package:babysitter_booking_app/models/jobs_model.dart';
import 'package:babysitter_booking_app/models/user_model.dart';

class Babysitter extends UserModel {
  String id, email, password, name, street, county;
  int wage;
  List<Job> jobs;
  List appliedJobs, assignedJobs, offeredJobs, recommends;

  Babysitter() : super() {
    this.wage = 0;
    this.jobs = [];
    this.appliedJobs =
        this.assignedJobs = this.offeredJobs = this.recommends = [];
  }
}
