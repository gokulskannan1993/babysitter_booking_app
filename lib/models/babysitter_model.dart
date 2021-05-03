import 'package:babysitter_booking_app/models/user_model.dart';

class Babysitter extends UserModel {
  String id, email, password, name, street, county;
  double wage;

  Babysitter() : super() {
    this.wage = 0;
  }
}
