import 'package:chat_app/core/constant/app_images.dart';
import 'package:chat_app/core/constant/logger.dart';
import 'package:chat_app/view/essential_view/chat/components/show_image_message.dart';
import 'package:chat_app/view/essential_view/chat/components/show_text_messages.dart';
import 'package:chat_app/view_model/chat_view_model.dart';
import 'package:chat_app/widgets/bottom_sheet/custom_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipe_to/swipe_to.dart';

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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ScrollController scrollController;
  List messagesList = [];
  late AnimationController animationController;
  String? replyMessage;
  final focusNode = FocusNode();

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

  void sendImageMessage() async {
    if (chatViewModel.imageFile != null) {
      setState(() {
        chatViewModel.sendImageMessage(
            widget.reciverUserId, widget.reciverUserToken);
        chatViewModel.imageFile = null;
      });
    }
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      setState(() {
        chatViewModel.sendMessage(widget.reciverUserId, messageController.text,
            widget.reciverUserToken, replyMessage);

        messageController.clear();
        scrollController.animateTo(scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 700), curve: Curves.easeIn);
      });
    } else {
      sendImageMessage();
    }
  }

  Widget buildMessageList() {
    return messagesStream == null
        ? const CircularProgressIndicator()
        : chatStreamWidget();
  }

  NotificationListener<ScrollNotification> chatStreamWidget() {
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
            return Center(
                child: CircularProgressIndicator(
                    color: Colors.purple,
                    backgroundColor: Colors.purple.shade100));
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
                      return Container();
                    } else {
                      DocumentSnapshot document = messagesList[index];
                      Map data = document.data() as Map<String, dynamic>;
                      // Check if the message is an image
                      final Timestamp timestamp =
                          data['timestamp'] as Timestamp;
                      final DateTime dateTime = timestamp.toDate();
                      final dateformate =
                          DateFormat('hh:mm a').format(dateTime);
                      if (data['type'] == 'image') {
                        return chatViewModel.isUploaded
                            ? const Center(child: CircularProgressIndicator())
                            : GestureDetector(
                                onHorizontalDragEnd: (value) {
                                  if (value.primaryVelocity! > 0) {
                                    logger.d("Right");
                                  } else {
                                    logger.d("Left");
                                  }
                                },
                                child: SwipeTo(
                                  onRightSwipe: (details) {
                                    replyToMessage(data['message']);
                                    focusNode.requestFocus();
                                  },
                                  child: ShowImageMessage(
                                    data: data,
                                    dateformat: dateformate,
                                  ),
                                ),
                              );
                      } else {
                        return SwipeTo(
                          onRightSwipe: (d) {
                            replyToMessage(data['message']);
                            focusNode.requestFocus();
                          },
                          child: ShowTextMessages(
                            data: data,
                            dateformat: dateformate,
                          ),
                        );
                      }
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
    final isREplaying = replyMessage != null;
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
                            Navigator.pop(context, true);
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
                          child: Column(
                            children: [
                              if (isREplaying) buildReplyBox(),
                              TextField(
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
                                            return CustomBottomSheet(
                                              reciverId: widget.reciverUserId,
                                              reciverToken:
                                                  widget.reciverUserToken,
                                            );
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
                                  fillColor: Colors.grey.shade100,
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: isREplaying
                                            ? Radius.zero
                                            : const Radius.circular(10),
                                        topRight: isREplaying
                                            ? Radius.zero
                                            : const Radius.circular(10),
                                        bottomLeft: const Radius.circular(10),
                                        bottomRight: const Radius.circular(10),
                                      ),
                                      borderSide: BorderSide.none),
                                ),
                                focusNode: focusNode,
                              ),
                            ],
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

  void replyToMessage(String message) {
    setState(() {
      replyMessage = message;
    });
  }

  onCancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  Widget buildReplyBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.shade400,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: ReplyMessageWidget(
        userName: widget.name,
        onCancelReply: onCancelReply,
        replyMessage: replyMessage ?? '',
      ),
    );
  }
}

class ReplyMessageWidget extends StatelessWidget {
  ReplyMessageWidget({
    super.key,
    required this.userName,
    required this.onCancelReply,
    required this.replyMessage,
  });
  String userName, replyMessage;
  final VoidCallback onCancelReply;
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            color: Colors.green,
            width: 4,
          ),
          const SizedBox(
            width: 4,
          ),
          Expanded(
            child: buildReply(),
          ),
        ],
      ),
    );
  }

  Column buildReply() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              userName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            GestureDetector(
              onTap: () => onCancelReply(),
              child: const Icon(Icons.close),
            )
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          replyMessage,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        )
      ],
    );
  }
}
