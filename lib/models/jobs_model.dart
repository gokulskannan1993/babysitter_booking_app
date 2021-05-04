import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class Job extends ChangeNotifier {
  String from, to, creator, assignedTo, status, date;

  Job() {
    this.from = this.to = this.creator = this.assignedTo = this.date = "";
    this.status = "incomplete";
  }
}
