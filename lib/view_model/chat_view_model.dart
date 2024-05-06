import 'dart:convert';

import 'dart:io';
import 'package:chat_app/core/constant/logger.dart';
import 'package:chat_app/model/chat_message_model.dart';
import 'package:chat_app/model/converstion_model.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';

class ChatViewModel with ChangeNotifier {
  String? reciverId;
  Timestamp? storeLastseen;
  bool isUploaded = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference converstionsCollection =
      FirebaseFirestore.instance.collection('converstions');
  File? imageFile;
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
  Future<void> sendMessage(String receiverId, String message,
      String receiverToken, String? replayMessage) async {
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
          type: message.isEmpty ? 'image' : 'text',
          imageUrl: message.isEmpty ? imageFile?.path : '',
          replayMessage: replayMessage ?? "");

      await converstionsCollection
          .doc(conversationId)
          .collection('messages')
          .add(model.toMap());
      sendNotificationToUser(receiverToken, message);
      notifyListeners();
    } else {
      createConversations(receiverId);
      sendMessage(receiverId, message, receiverToken, replayMessage);
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
            'key=AAAAmx_gE_0:APA91bFo_afy4NtGwcdbh_0TVK4qwcVgRSD_C9WoT1cEKbyVXUySwE5jljeV65GC9VW2RikM6Cp9mXaKCoVeP-0gZkTd-wauRyrMm01JH_trPsnwQP8Z5Wov3BPN_2QcjqBatfCzKZSS',
      },
      body: jsonEncode(messageBody),
    );

    if (response.statusCode == 200) {
      logger.d('Notification sent successfully');
      messagingViewModel.initPushNotifications();
    } else {
      logger.d('Failed to send notification');
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
    logger.d('conversationId: $conversationId');
    if (conversationId != null) {
      yield* converstionsCollection
          .doc(conversationId!)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
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
            ConverstionModel(userIds: userIds, conversationsUserData: [
          ConversationsUserDataModel(
                  lastSeen: lastSeen ?? Timestamp.now(), userId: currentUserUid)
              .toMap(),
          ConversationsUserDataModel(
                  lastSeen: lastSeen ?? Timestamp.now(), userId: receiverId)
              .toMap(),
        ]);

        final Map<String, dynamic> data = model.toMap();

        final DocumentReference docRef = await converstionsCollection.add(data);

        model.converstionsId = docRef.id;

        final Map<String, dynamic> updatedData = model.toMap();

        await docRef.update(updatedData);
      } else {
        logger.d('Last Seen $lastSeen');
        final conversationId = existingConversations.docs.first.id;
        final Map<String, dynamic> existingData =
            existingConversations.docs.first.data() as Map<String, dynamic>;

        existingData[currentUserUid]['lastMessageSend'] = lastSeen;

        existingData[receiverId]['lastMessageSend'] = lastSeen;
        updateConversation(
            currentUserUid, receiverId, lastSeen ?? Timestamp.now());
      }
      return true;
    } on Exception catch (e) {
      logger.d('Error: ${e.toString()}');
      return false;
    }
  }

  Future<void> updateConversation(
      String currentUserUid, String reciverId, Timestamp lastSeen) async {
    try {
      List<String> ids = [currentUserUid, reciverId];
      ids.sort();
      String chatRoomId = ids.join('_');
      await getIds(ids);
      logger.d(conversationId.toString());
      final conversationDoc =
          await converstionsCollection.doc(conversationId).get();
      if (conversationDoc.exists) {
        final data = conversationDoc.data() as Map<String, dynamic>;
        final conversationsUserData =
            data['conversationsUserData'] as List<dynamic>;

        for (int i = 0; i < conversationsUserData.length; i++) {
          final userData = conversationsUserData[i] as Map<String, dynamic>;
          if (userData['userId'] == currentUserUid) {
            userData['lastMessageSend'] = lastSeen;
            conversationsUserData[i] = userData;
          }
        }

        await converstionsCollection.doc(conversationId).update({
          'conversationsUserData': conversationsUserData,
        });

        notifyListeners();
      } else {
        logger.d('Conversation document does not exist');
      }
    } catch (e) {
      logger.d('Error updating conversation: $e');
    }
  }

  Future getImages() async {
    ImagePicker imagePicker = ImagePicker();
    await imagePicker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImageToFirebase();
      }
    });
  }

  Future<void> getImagesFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    final XFile? xFile =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      imageFile = File(xFile.path);
      uploadImageToFirebase();
    }
  }

  Future<void> sendImageMessage(String receiverId, String receiverToken) async {
    final String userCurrentId = auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [userCurrentId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    getIds(ids);
    final existingConversations =
        await converstionsCollection.where('userIds', isEqualTo: ids).get();

    if (existingConversations.docs.isNotEmpty) {
      isUploaded = true;
      String conversationId = existingConversations.docs.first.id;
      createConversations(receiverId);

      String imagePath = await uploadImageToFirebase().then((value) async {
        final model = ChatMessageModel(
          message: '',
          senderId: userCurrentId,
          reciverId: receiverId,
          timestamp: timestamp,
          type: 'image',
          imageUrl: value,
        );

        await converstionsCollection
            .doc(conversationId)
            .collection('messages')
            .add(model.toMap());
        sendNotificationToUser(receiverToken, 'Image');
        isUploaded = false;
        notifyListeners();
        return value;
      });
    } else {
      createConversations(receiverId);
      sendImageMessage(receiverId, receiverToken);
    }
  }

  Future<String> uploadImageToFirebase() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);
    String imagePath = await uploadTask.ref.getDownloadURL();
    logger.d('ImagePath: $imagePath');
    return imagePath;
  }
}
