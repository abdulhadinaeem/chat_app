import 'package:cloud_firestore/cloud_firestore.dart';

class ConverstionModel {
  List? userIds = [];
  Timestamp? lastMessageSend;
  String? converstionsId;
  Map? conversationsUserData;
  ConverstionModel(
      {this.userIds,
      this.lastMessageSend,
      this.converstionsId,
      this.conversationsUserData});
  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'lastMessageSend': lastMessageSend,
      'converstionsId': converstionsId,
      'conversationsUserData': conversationsUserData
    };
  }
}

class ConversationsUserDataModel {}
