import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/constant/app_globals.dart';
import 'package:chat_app/core/constant/app_images.dart';
import 'package:chat_app/core/constant/route_names.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/model/user_data_model.dart';
import 'package:chat_app/view_model/chat_view_model.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:chat_app/view_model/user_data_view_model.dart';
import 'package:chat_app/widgets/progress_indicator/custom_progress_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, this.name});
  String? name;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Stream<QuerySnapshot> userCollection;
  List<UserDataModel> userDataList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final provider = Provider.of<UserDataServices>(context, listen: false);
    provider.fetchLastSeenTime().then((value) {
      log('R-ID: ${provider.reciverId.toString()}');
      provider.startListeningForUnreadMessages();
      log('IsEmpty: ${provider.lastMessagesLength!.isEmpty}');
    });
    @override
    void dispose() {
      final provider = Provider.of<UserDataServices>(context, listen: false);
      provider.stopListeningForUnreadMessages();
      super.dispose();
    }

    // provider.getNewMessagesCount();
    // provider.lastMessagesLength = provider.getNewMessagesCount().toString();
    provider.setStatus('Online');
    userCollection =
        FirebaseFirestore.instance.collection('userCollection').snapshots();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final provider = Provider.of<UserDataServices>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      provider.setStatus('Online');
    } else {
      provider.setStatus('Offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserDataServices>(
        builder: (context, UserDataServices provider, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: userCollection,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      color: Colors.purple,
                      backgroundColor: Colors.purple.shade100),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Scaffold(
                  body: Center(
                    child: Text('No User Found'),
                  ),
                );
              }
              userDataList.clear();
              for (var data in snapshot.data!.docs) {
                // userDataList.removeWhere((element) =>
                //     element.id == FirebaseAuth.instance.currentUser?.uid);
                userDataList.add(
                    UserDataModel.fromMap(data.data() as Map<String, dynamic>));
                log('${userDataList.toList()}');
              }

              return Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    'Messages',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white70.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 0.3, color: Colors.white),
                                    ),
                                    child: const Icon(
                                      Icons.more_vert_sharp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final result = await showMenu(
                                      context: context,
                                      position: const RelativeRect.fromLTRB(
                                          100, 10, 0, 0),
                                      items: [
                                        const PopupMenuItem(
                                          value: "New group",
                                          child: Text("New group"),
                                        ),
                                        const PopupMenuItem(
                                          value: "New broadcast",
                                          child: Text("New broadcast"),
                                        ),
                                        const PopupMenuItem(
                                          value: "Starred messages",
                                          child: Text("Starred messages"),
                                        ),
                                        const PopupMenuItem(
                                          value: "Settings",
                                          child: Text("Settings"),
                                        ),
                                        PopupMenuItem(
                                          value: "Log out",
                                          child: const Text("Log out"),
                                          onTap: () async {
                                            provider.setStatus('Offline');
                                            MessagingViewModel().deleteToken();
                                            provider.logout();
                                            await FirebaseAuth.instance
                                                .signOut()
                                                .then((value) {
                                              context.read<AuthState>().user =
                                                  null;

                                              Navigator.pushNamed(context,
                                                  RouteNames.logInScreen);
                                            });
                                          },
                                        ),
                                      ],
                                    );

                                    if (result != null) {
                                      print(result);
                                    }
                                  },
                                )
                              ],
                            ),
                            //Online Users List.....
                            Expanded(
                              child: ListView.builder(
                                  itemCount: userDataList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    if (userDataList[index].id ==
                                        FirebaseAuth
                                            .instance.currentUser?.uid) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircleAvatar(
                                            radius: 36,
                                            backgroundImage: NetworkImage(
                                                AppImages.profilePic),
                                          ),
                                          Text(
                                            userDataList[index].name ?? "",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      userDataList.isEmpty
                          ? const CircularProgressIndicator()
                          : Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  final userData = userDataList[index];
                                  if (currentUser != null &&
                                      userData.email == currentUser.email) {
                                    return const SizedBox.shrink();
                                  }
                                  return const Divider();
                                },
                                itemCount: userDataList.length,
                                itemBuilder: (context, index) {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  final userData = userDataList[index];
                                  if (currentUser != null &&
                                      userData.email == currentUser.email) {
                                    return const SizedBox.shrink();
                                  }
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          NetworkImage(AppImages.profilePic),
                                    ),
                                    title: Text(userData.name ?? ""),
                                    trailing: provider.lastMessagesLength == '0'
                                        ? const SizedBox()
                                        : CircleAvatar(
                                            backgroundColor: Colors.purple,
                                            radius: 11,
                                            child: Text(
                                              provider.lastMessagesLength
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                    onTap: () {
                                      if (userData.name != null &&
                                          userData.id != null) {
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.chatScreen,
                                          arguments: {
                                            'name': userData.name!,
                                            'receiverUserId': userData.id!,
                                            'status': userData.status,
                                            'reciverUserToken':
                                                userData.fcmToken
                                          },
                                        );
                                      } else {
                                        log('Error');
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
