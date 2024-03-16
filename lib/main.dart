import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_push_notification/firebase_options.dart';
import 'package:simple_push_notification/screens/home_screen.dart';
import 'package:simple_push_notification/screens/notifications_screen.dart';

import 'services/firebase_messaging_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingService().initFirebaseMessaging();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
      routes: {NotificationsScreen.route: (context) => const NotificationsScreen()},
    );
  }
}


