import 'package:chat_app/core/constant/route_names.dart';
import 'package:chat_app/view/essential_view/chat/chat_screen.dart';
import 'package:chat_app/view/essential_view/home/home_screen.dart';
import 'package:chat_app/view/initial_view.dart/login_screen.dart';
import 'package:chat_app/view/initial_view.dart/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class AppRoutes {
  static Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.signUpScreen:
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case RouteNames.logInScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case RouteNames.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case RouteNames.chatScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final name = args['name'] as String;
        final receiverUserId = args['receiverUserId'] as String;
        final status = args['status'] as String;
        final reciverUserToken = args['reciverUserToken'] as String;
        return PageTransition(
            child: ChatScreen(
              name: name,
              reciverUserId: receiverUserId,
              status: status,
              reciverUserToken: reciverUserToken,
            ),
            type: PageTransitionType.fade);
    }
    return MaterialPageRoute(builder: (_) {
      return Container();
    });
  }
}
