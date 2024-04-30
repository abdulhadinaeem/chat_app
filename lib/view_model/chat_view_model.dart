import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/model/chat_message_model.dart';
import 'package:chat_app/model/converstion_model.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as https;

class ChatViewModel extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference converstionsCollection =
      FirebaseFirestore.instance.collection('converstions');
  String? conversationId;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  MessagingViewModel messagingViewModel = MessagingViewModel();
  void initializeLocalNotifications() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_launcher'),
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //SEND MESSAGE
  Future<void> sendMessage(
      String receiverId, String message, String receiverToken) async {
    final String userCurrentId = auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [userCurrentId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    getIds(ids);
    final existingConversations =
        await converstionsCollection.where('userIds', isEqualTo: ids).get();

    if (existingConversations.docs.isNotEmpty) {
      String conversationId = existingConversations.docs.first.id;
      createConversations(receiverId);
      final model = ChatMessageModel(
        message: message,
        senderId: userCurrentId,
        reciverId: receiverId,
        timestamp: timestamp,
      );

      await converstionsCollection
          .doc(conversationId)
          .collection('messages')
          .add(model.toMap());
      sendNotificationToUser(receiverToken, message);
      notifyListeners();
    } else {
      // If no conversation exists, create a new one and retry sending the message
      createConversations(receiverId);
      // Retry sending the message
      sendMessage(receiverId, message, receiverToken);
    }
  }

  Future<void> sendNotificationToUser(
      String receiverToken, String message) async {
    final messageBody = {
      'notification': {
        'title': 'New Message',
        'body': message,
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'sender_id': auth.currentUser!.uid,
      },
      'to': receiverToken,
    };

    final response = await https.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAmx_gE_0:APA91bFo_afy4NtGwcdbh_0TVK4qwcVgRSD_C9WoT1cEKbyVXUySwE5jljeV65GC9VW2RikM6Cp9mXaKCoVeP-0gZkTd-wauRyrMm01JH_trPsnwQP8Z5Wov3BPN_2QcjqBatfCzKZSS', // Replace with your server key
      },
      body: jsonEncode(messageBody),
    );

    if (response.statusCode == 200) {
      log('Notification sent successfully');
      messagingViewModel.initPushNotifications();
    } else {
      log('Failed to send notification');
    }
  }

  Future<void> showLocalNotification(String message) async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High_Important_Notifications',
      description: 'This channel is used for local notification',
      importance: Importance.max,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      icon: '@drawable/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Message',
      message,
      platformChannelSpecifics,
    );
  }

  getIds(List ids) async {
    final existingConversations =
        await converstionsCollection.where('userIds', isEqualTo: ids).get();
    conversationId = existingConversations.docs.first.id;
  }

  //GET MESSAGE..
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String userCurrentId,
    String receiverId,
  ) async* {
    List<String> ids = [userCurrentId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await getIds(ids);
    log('conversationId: $conversationId');
    if (conversationId != null) {
      yield* converstionsCollection
          .doc(conversationId!)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      // Return an empty stream if conversationId is null
      yield* const Stream.empty();
    }
  }

  Future<bool> createConversations(String receiverId,
      [Timestamp? lastSeen]) async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final userIds = [currentUserUid, receiverId];
      userIds.sort();

      final existingConversations = await converstionsCollection
          .where('userIds', isEqualTo: userIds)
          .get();

      if (existingConversations.docs.isEmpty) {
        final model =
            ConverstionModel(userIds: userIds, conversationsUserData: {
          'UserId': currentUserUid,
          'lastMessageSend': lastSeen,
        });

        final Map<String, dynamic> data = model.toMap();

        final DocumentReference docRef = await converstionsCollection.add(data);

        model.converstionsId = docRef.id;

        final Map<String, dynamic> updatedData = model.toMap();

        await docRef.update(updatedData);
      } else {
        // final conversationId = existingConversations.docs.first.id;
        converstionsCollection.doc(conversationId).update({
          'conversationsUserData': [
            {'lastMessageSend': lastSeen}
          ]
        });
      }
      return true;
    } on Exception catch (e) {
      return false;
    }
  }
}
