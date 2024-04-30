import 'package:chat_app/core/constant/route_names.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:chat_app/view_model/user_data_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.purple,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MessagingViewModel().getFirebaseToken();
  MessagingViewModel().initPushNotifications();
  MessagingViewModel().initLocalNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserDataServices(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: PageTransition(
                      type: PageTransitionType.rightToLeft, child: this)
                  .matchingBuilder,
            },
          ),
        ),
        onGenerateRoute: AppRoutes.routes,
        initialRoute: determineInitialRoute(),
        navigatorKey: navigatorKey,
        routes: const {},
      ),
    );
  }

  String determineInitialRoute() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return RouteNames.homeScreen;
    } else {
      return RouteNames.signUpScreen;
    }
  }
}

class AuthState with ChangeNotifier {
  int? _user;
  int? get user => _user;
  set user(int? newUser) {
    _user = newUser;
  }
}
