import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class Job extends ChangeNotifier {
  String from, to, creator, assignedTo, status, date, askedTo, askedBy;
  int maxWage;

  Job() {
    this.from = this.to =
        this.creator = this.assignedTo = this.date = askedTo = askedBy = "";
    this.status = "incomplete";
    this.maxWage = 10;
  }
}
