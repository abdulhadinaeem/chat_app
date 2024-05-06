import 'package:chat_app/model/chat_message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShowTextMessages extends StatelessWidget {
  ShowTextMessages({
    super.key,
    required this.data,
    required this.dateformat,
  });
  Map data;
  final auth = FirebaseAuth.instance;
  String dateformat;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: data['senderId'] == auth.currentUser?.uid
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: data['senderId'] == auth.currentUser?.uid ? 50 : 20,
                right: data['senderId'] == auth.currentUser?.uid ? 20 : 50,
                bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                color: data['senderId'] == auth.currentUser?.uid
                    ? Colors.purple
                    : const Color.fromARGB(255, 125, 125, 125),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['message'],
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Text(
                      dateformat,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
