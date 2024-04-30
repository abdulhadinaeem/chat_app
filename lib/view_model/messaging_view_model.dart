import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/core/constant/route_names.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackGroungMessage(RemoteMessage message) async {
  print('Title:${message.notification?.title}');
  print('Body:${message.notification?.body}');
  print('PayLoad:${message.data}');
}

class MessagingViewModel {
  String? fCMToken;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High_Important_Notifications',
      description: 'This channel is used for local notification',
      importance: Importance.defaultImportance);
  final localNotification = FlutterLocalNotificationsPlugin();

  void handelMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(RouteNames.chatScreen);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => handelMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handelMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackGroungMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  androidChannel.id, androidChannel.name,
                  channelDescription: androidChannel.description,
                  icon: '@drawable/ic_launcher')),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    await localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (payLoad) {
        final message = RemoteMessage.fromMap(jsonDecode(payLoad.payload!));
        handelMessage(message);
      },
    );
    final platform = localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidChannel);
  }

  Future deleteToken() async {
    await messaging.deleteToken();
    final document = await FirebaseFirestore.instance
        .collection('userCollection')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (document.docs.isNotEmpty) {
      final userDoc = document.docs.first;

      await FirebaseFirestore.instance
          .collection('userCollection')
          .doc(userDoc.id)
          .update({'fcmToken': ''});
    }
  }

  Future getFirebaseToken() async {
    await messaging.requestPermission();
    fCMToken = await messaging.getToken();
    log(fCMToken.toString());
    fCMToken = fCMToken.toString();
    return fCMToken;
  }
}
