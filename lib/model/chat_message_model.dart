// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  String? message;
  String? reciverId;
  String? senderId;
  String? imageUrl;
  Timestamp? timestamp;
  String? type;
  String? replayMessage;
  ChatMessageModel({
    this.message,
    this.reciverId,
    this.senderId,
    this.imageUrl,
    this.timestamp,
    this.type,
    this.replayMessage,
  });

  ChatMessageModel copyWith({
    String? message,
    String? reciverId,
    String? senderId,
    String? imageUrl,
    Timestamp? timestamp,
    String? type,
    String? replayMessage,
  }) {
    return ChatMessageModel(
      message: message ?? this.message,
      reciverId: reciverId ?? this.reciverId,
      senderId: senderId ?? this.senderId,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      replayMessage: replayMessage ?? this.replayMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'reciverId': reciverId,
      'senderId': senderId,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'type': type,
      'replayMessage': replayMessage,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      message: map['message'] != null ? map['message'] as String : null,
      reciverId: map['reciverId'] != null ? map['reciverId'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      timestamp:
          map['timestamp'] != null ? map['timestamp'] as Timestamp : null,
      type: map['type'] != null ? map['type'] as String : null,
      replayMessage:
          map['replayMessage'] != null ? map['replayMessage'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatMessageModel(message: $message, reciverId: $reciverId, senderId: $senderId, imageUrl: $imageUrl, timestamp: $timestamp, type: $type, replayMessage: $replayMessage)';
  }

  @override
  bool operator ==(covariant ChatMessageModel other) {
    if (identical(this, other)) return true;

    return other.message == message &&
        other.reciverId == reciverId &&
        other.senderId == senderId &&
        other.imageUrl == imageUrl &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.replayMessage == replayMessage;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        reciverId.hashCode ^
        senderId.hashCode ^
        imageUrl.hashCode ^
        timestamp.hashCode ^
        type.hashCode ^
        replayMessage.hashCode;
  }
}
