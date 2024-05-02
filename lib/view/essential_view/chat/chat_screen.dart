import 'dart:developer';

import 'package:chat_app/core/constant/app_images.dart';
import 'package:chat_app/view_model/chat_view_model.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:chat_app/widgets/bottom_sheet/custom_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {super.key,
      required this.name,
      required this.reciverUserId,
      required this.status,
      required this.reciverUserToken});
  String name;
  String reciverUserId;
  String reciverUserToken;
  String status;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late ChatViewModel chatViewModel;
  late Stream<QuerySnapshot> messagesStream = const Stream.empty();
  TextEditingController messageController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ScrollController scrollController;
  CollectionReference converstionsCollection =
      FirebaseFirestore.instance.collection('converstions');
  List messagesList = [];
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = BottomSheet.createAnimationController(this);

    animationController.duration = const Duration(milliseconds: 800);
    animationController.reverseDuration = const Duration(milliseconds: 800);
    animationController.drive(CurveTween(curve: Curves.easeIn));
    scrollController = ScrollController(initialScrollOffset: 0.0);
    chatViewModel = ChatViewModel();
    fetchOrCreateConversationId();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  void fetchOrCreateConversationId() async {
    setState(
      () {
        messagesStream = chatViewModel.getMessages(
          FirebaseAuth.instance.currentUser!.uid,
          widget.reciverUserId,
        );
      },
    );
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      setState(
        () {
          chatViewModel.sendMessage(widget.reciverUserId,
              messageController.text, widget.reciverUserToken);

          messageController.clear();
        },
      );
    }
  }

  Widget buildMessageList() {
    return messagesStream == null
        ? const CircularProgressIndicator()
        : ChatStreamWidget();
  }

  NotificationListener<ScrollNotification> ChatStreamWidget() {
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.extentAfter == 0) {
          scrollToBottom();
        }
        return true;
      },
      child: StreamBuilder(
        stream: messagesStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Connection state: Waiting');
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            messagesList = snapshot.data!.docs.toList();

            return AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 800),
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: messagesList.length + 1,
                  controller: scrollController,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (index == messagesList.length) {
                      return Container(
                          // height: 70,
                          );
                    } else {
                      DocumentSnapshot document = messagesList[index];
                      Map data = document.data() as Map<String, dynamic>;
                      log('message${data['message']}');
                      print('data:$data');
                      final Timestamp timestamp =
                          data['timestamp'] as Timestamp;
                      final DateTime dateTime = timestamp.toDate();
                      final dateformate =
                          DateFormat('hh:mm a').format(dateTime);
                      return Container(
                        alignment: data['senderId'] == auth.currentUser?.uid
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 20),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.only(
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
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: Text(
                                        dateformate,
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
                  },
                ),
              ),
            );
          } else {
            print('Connection state: ${snapshot.connectionState}');
            return const SizedBox();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    final timeStamp = Timestamp.now();
    chatViewModel.updateConversation(FirebaseAuth.instance.currentUser!.uid,
        widget.reciverUserId, timeStamp);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: ListTile(
                  leading: SizedBox(
                    width: 93,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final timeStamp = Timestamp.now();
                            chatViewModel.updateConversation(
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.reciverUserId,
                                timeStamp);
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(AppImages.profilePic),
                            radius: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          AppImages.videoCallIcon,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          AppImages.phoneCallIcon,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  subtitle: Text(
                    widget.status,
                    style: TextStyle(
                        color: widget.status == 'Online'
                            ? Colors.green
                            : Colors.grey),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(child: buildMessageList()),
              Form(
                key: formKey,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: messageController,
                            maxLines: 4,
                            minLines: 1,
                            autocorrect: true,
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {
                                  if (animationController.isCompleted ||
                                      animationController.isDismissed) {
                                    showModalBottomSheet(
                                      context: context,
                                      transitionAnimationController:
                                          animationController,
                                      builder: (_) {
                                        return const CustomBottomSheet();
                                      },
                                    );
                                  }
                                },
                                icon: SvgPicture.asset(
                                  AppImages.attachFileIcon,
                                  height: 24,
                                  color: Colors.grey,
                                ),
                              ),
                              focusColor: Colors.black,
                              hintText: 'Message',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.purple),
                        child: IconButton(
                          onPressed: () {
                            sendMessage();
                          },
                          icon: SvgPicture.asset(
                            AppImages.sendMessageIcon,
                            color: Colors.white,
                            alignment: Alignment.center,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
