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
      followers,
      profileImage;

  List contacts;

  UserModel() {
    this.id = this.email = this.password = this.name = this.street =
        this.county = this.about =
            this.phone = this.recommends = this.rating = this.followers = "";

    this.contacts = [];

    this.profileImage =
        "https://firebasestorage.googleapis.com/v0/b/babywatch-1593f.appspot.com/o/blank-profile-picture-973460_1280-1.png?alt=media&token=294b5400-84b7-467d-a415-b4e6a7843ed5";
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
