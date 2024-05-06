import 'package:chat_app/model/chat_message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class ShowImageMessage extends StatelessWidget {
  ShowImageMessage({
    super.key,
    required this.data,
    required this.dateformat,
  });
  Map data;
  final auth = FirebaseAuth.instance;
  String dateformat;

  goToImageScreen(
    BuildContext context,
    Map data,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: Hero(
              tag: 'image',
              child: Image.network(
                data['imageUrl'],
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: data['senderId'] == auth.currentUser?.uid
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              goToImageScreen(context, data);
            },
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              margin: const EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: data['senderId'] == auth.currentUser?.uid
                    ? Colors.purple
                    : const Color.fromARGB(255, 125, 125, 125),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Hero(
                tag: 'image',
                child: Image.network(
                  data['imageUrl'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.white54,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Text(
              dateformat,
              style: const TextStyle(
                fontSize: 11,
                color: Color.fromARGB(255, 125, 125, 125),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
