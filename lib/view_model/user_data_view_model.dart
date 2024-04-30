import 'dart:developer';

import 'package:chat_app/core/constant/app_globals.dart';
import 'package:chat_app/model/user_data_model.dart';
import 'package:chat_app/view_model/chat_view_model.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class UserDataServices with ChangeNotifier {
  CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('userCollection');
  MessagingViewModel messagingViewModel = MessagingViewModel();
  ChatViewModel chatViewModel = ChatViewModel();
  String? lastMessagesLength;
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

      return userDataCollection.add(user.toMap()).then((value) {
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

  getLengthofLastMessages(String reciverId) {
    var a = chatViewModel.getlength(reciverId);
    lastMessagesLength = a.toString();
    notifyListeners();
  }
}
