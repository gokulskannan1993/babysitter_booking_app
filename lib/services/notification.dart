import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// notification for new message
void showNotification(String title, String desc) {
  var androidSpecifics = AndroidNotificationDetails(
    "message_notif",
    "message_notif",
    "Channel for message notification",
  );

  var platformSpecifics = NotificationDetails(android: androidSpecifics);
  flutterLocalNotificationsPlugin.show(0, title, desc, platformSpecifics);
}

//get all notifications from the user
void getNotifications(String userid) async {
  //instance of firestore
  final _notfications = FirebaseFirestore.instance.collection('notfications');

  await for (var snapshot
      in _notfications.where('target', isEqualTo: userid).snapshots()) {
    for (var notification in snapshot.docs) {
      showNotification(
          notification.data()['title'], notification.data()['desc']);
      _notfications.doc(notification.id).delete();
    }
  }
}
