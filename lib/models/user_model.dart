import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String id,
      email,
      password,
      name,
      street,
      county,
      about,
      phone,
      rating,
      recommends,
      followers;

  UserModel() {
    this.id = this.email = this.password = this.name = this.street =
        this.county = this.about =
            this.phone = this.recommends = this.rating = this.followers = "";
  }

  UserModel.overloadedContructorNamedArguemnts(
      {this.email,
      this.id,
      this.phone,
      this.street,
      this.county,
      this.about,
      this.name});
}
