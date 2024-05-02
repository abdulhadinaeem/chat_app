import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/constant/app_globals.dart';
import 'package:chat_app/model/user_data_model.dart';
import 'package:chat_app/view_model/chat_view_model.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class UserDataServices with ChangeNotifier {
  CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('userCollection');
  CollectionReference converstionsCollection =
      FirebaseFirestore.instance.collection('converstions');

  String? conversationId;
  MessagingViewModel messagingViewModel = MessagingViewModel();
  ChatViewModel chatViewModel = ChatViewModel();
  String? lastMessagesLength;
  StreamSubscription? _unreadMessagesSubscription;
  String? reciverId;
  Timestamp? userLastSeen;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List userDataList = [];
  List onlineUsersList = [];
  final userCollection =
      FirebaseFirestore.instance.collection('userCollection');
  void setStatus(String status) async {
    final document = await userCollection
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (document.docs.isNotEmpty) {
      final userDoc = document.docs.first;

      await userCollection.doc(userDoc.id).update({
        'status': status,
      });

      print('Status updated successfully');
    } else {
      print('User document not found');
    }
  }

//UPDATE ACC DATA...
  updateAccountData({String? email, String? passWord}) {
    MessagingViewModel().getFirebaseToken().then((value) async {
      log('FcmToken: ${value.toString()}');
      final document =
          await userCollection.where('email', isEqualTo: email).get();
      if (document.docs.isNotEmpty) {
        final userDoc = document.docs.first;

        await userCollection.doc(userDoc.id).update({
          'fcmToken': value.toString(),
          'status': 'Online',
        });
        notifyListeners();
      }
    });
  }

  //STORE ACCOUNT DATA..
  storeAccountData(context,
      {String? name, String? email, String? passWord}) async {
    await messagingViewModel.getFirebaseToken().then((value) {
      final user = UserDataModel(
        name: name,
        id: FirebaseAuth.instance.currentUser!.uid,
        email: email,
        passWord: passWord,
        status: 'Online',
        fcmToken: value.toString(),
      );

      notifyListeners();

      DocumentReference ref =
          userDataCollection.doc(FirebaseAuth.instance.currentUser?.uid);
      ref.set(user.toMap()).then((value) {
        userDataList.add(user);

        notifyListeners();
      });
    });
  }

  logout() {
    currentUserName = "";
    notifyListeners();
  }

  //GET ONLINE USERS.....
  Future<void> getOnlineUsers() async {
    onlineUsersList.clear();
    final snapshot = await FirebaseFirestore.instance
        .collection('userCollection')
        .where('status', isEqualTo: 'Online')
        .get();
    for (var element in snapshot.docs) {
      onlineUsersList.add(UserDataModel.fromMap(element.data()));
    }
    notifyListeners();
  }

//GET USERS DATA....
  Future<void> getUserData() async {
    userDataList.clear();
    final snapshot =
        await FirebaseFirestore.instance.collection('userCollection').get();
    for (var element in snapshot.docs) {
      userDataList.removeWhere(
          (element) => element.id == FirebaseAuth.instance.currentUser?.uid);
      userDataList.add(UserDataModel.fromMap(element.data()));
    }
    notifyListeners();
  }

  getIds() async {
    List<String> ids = [auth.currentUser!.uid, reciverId!];
    final existingConversations =
        await converstionsCollection.where('userIds', isEqualTo: ids).get();
    conversationId = existingConversations.docs.first.id;
  }

  void startListeningForUnreadMessages() {
    _unreadMessagesSubscription =
        Stream.periodic(const Duration(seconds: 2)).listen((_) {
      fetchLastSeenTime();
      notifyListeners();
    });
  }

  void stopListeningForUnreadMessages() {
    _unreadMessagesSubscription?.cancel();
  }

  Future<void> fetchLastSeenTime() async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final existingConversations = await converstionsCollection
          .where('userIds', arrayContains: currentUserUid)
          .get();

      for (final doc in existingConversations.docs) {
        Map data = doc.data() as Map<String, dynamic>;
        final conversationUserData = data['conversationsUserData'];

        final userLastSeen = conversationUserData.firstWhere((userData) =>
            userData['userId'] == currentUserUid)['lastMessageSend'];

        conversationId = doc.id;

        final messages = await converstionsCollection
            .doc(conversationId)
            .collection('messages')
            .where('senderId', isNotEqualTo: currentUserUid)
            .where('timestamp', isGreaterThan: userLastSeen)
            .get();
        lastMessagesLength = messages.docs.length.toString();
        log('Unread Messages Count: ${messages.docs.length}');
        log('lastMessagesLength: $lastMessagesLength');

        // Notify listeners of the change
        notifyListeners();
      }
    } catch (e) {
      log('Error fetching last seen time: $e');
    }
  }
}
