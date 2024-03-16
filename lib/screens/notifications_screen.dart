import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simple_push_notification/widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const route = '/notification-screen';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final RemoteMessage message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: Column(
          children: [
            NotificationTile(
              notificationTitle: message.notification?.title ?? '',
              notificationBody: message.notification?.body ?? '',
              payload: message.data,
            ),
          ],
        ));
  }
}
