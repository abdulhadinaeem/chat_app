// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessageModel {
  String? message;
  String? reciverId;
  String? senderId;
  Timestamp? timestamp;
  ChatMessageModel({
    this.message,
    this.reciverId,
    this.senderId,
    this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'reciverId': reciverId,
      'message': message,
      'timestamp': timestamp
    };
  }
}
