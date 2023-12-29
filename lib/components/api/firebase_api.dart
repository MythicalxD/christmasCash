import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: "key1",
          title: message.notification?.title,
          body: message.notification?.body));
}

late var settings;
bool isEnabled = false;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      isEnabled = true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      isEnabled = false;
    } else {
      isEnabled = false;
    }
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance
        .subscribeToTopic("topic")
        .then((value) => print("Subscribed !"));
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
