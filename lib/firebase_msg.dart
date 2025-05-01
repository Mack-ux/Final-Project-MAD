import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart';

class FirebaseMsg {
  final msgService = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    await msgService.requestPermission();

    var token = await msgService.getToken();
    print("Token: $token");

    FirebaseMessaging.onMessage.listen(handleNotification);
  }
}

Future<void> handleNotification(RemoteMessage msg) async {
  RemoteNotification? notification = msg.notification;

  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title ?? 'No Title',
      notification.body ?? 'No Body',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel_id',
          'Default Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
