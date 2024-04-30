import 'package:cloud_firestore/cloud_firestore.dart';

class ConverstionModel {
  List? userIds = [];

  String? converstionsId;
  List<Map<String, dynamic>>? conversationsUserData;
  ConverstionModel(
      {this.userIds, this.converstionsId, this.conversationsUserData});
  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'converstionsId': converstionsId,
      'conversationsUserData':
          conversationsUserData?.map((userData) => userData).toList(),
    };
  }
}

class ConversationsUserDataModel {
  String? userId;
  Timestamp? lastSeen;
  ConversationsUserDataModel({this.lastSeen, this.userId});
  Map<String, dynamic> toMap() {
    return {'userId': userId, 'lastSeen': lastSeen};
  }
}
