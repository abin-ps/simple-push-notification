import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_push_notification/main.dart';
import 'package:simple_push_notification/screens/notifications_screen.dart';
import 'package:simple_push_notification/services/local_notifications_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //simple push notification channel group
  final _simplePushNotificChannelGrp = const AndroidNotificationChannelGroup(
    'simple_push_notific_channel',
    'Simple Push Notification Channel',
    description: 'This channel is used for testing notification on all the possible states of app',
  );

  //android notification channel
  final AndroidNotificationChannel androidNotificChannel = const AndroidNotificationChannel(
    'simple_push_notific_channel',
    'Simple Push Notification Channel',
    description: 'This channel is used for testing notification on all the possible states of app',
    importance: Importance.max,
  );

  // final AndroidNotificationChannel _backgroundHeadupChannel = const AndroidNotificationChannel(
  //   'background_headup_notification_channel',
  //   'Background Headup Notification Channel',
  //   description: 'This channel is used for testing headup notification from app running in background state',
  //   importance: Importance.high,
  // );

  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    print(notification?.title);
    print(notification?.body);
    print('Payload: ${message.data}');
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationsScreen.route, arguments: message);
  }

  Future initPushNotification() async {
    //set notification preferences for iOS
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions();
    //calls app opened from terminated state, on notification tapped
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      final notification = message?.notification;
      if (notification != null) {
        _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidNotificChannel.id,
              androidNotificChannel.name,
              channelDescription: androidNotificChannel.description,
            ),
          ),
          payload: jsonEncode(message?.toMap()),
        );
      }
      handleMessage(message);
    });
    //calls when app opened from background (app runnign in background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidNotificChannel.id,
              androidNotificChannel.name,
              channelDescription: androidNotificChannel.description,
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      }
      handleMessage(message);
    });
    //call notification received from terminated or app running in background state
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    //on message listener - trigger when app is in foreground and
    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationsServic().showNotification(
        message: message,
        androidNotificChannel: androidNotificChannel,
      );

      // final notification = message.notification;
      // if (notification == null) return;
      // _localNotification.show(
      //   notification.hashCode,
      //   notification.title,
      //   notification.body,
      //   NotificationDetails(
      //     android: AndroidNotificationDetails(_androidNotificChannel.id, _androidNotificChannel.name,
      //         channelDescription: _androidNotificChannel.description,
      //         showProgress: true,
      //         progress: 20,
      //         maxProgress: 100,
      //         visibility: NotificationVisibility.public,
      //         priority: Priority.max,
      //         importance: Importance.max,
      //         onlyAlertOnce: true,
      //         ticker: 'ticker'),
      //   ),
      //   payload: jsonEncode(message.toMap()),
      // );
    });
  }

  // Future initLocalNotifications() async {
  //   const iOS = DarwinInitializationSettings();
  //   const android = AndroidInitializationSettings('@drawable/ic_launcher');
  //   const settings = InitializationSettings(android: android, iOS: iOS);

  //   await _localNotification.initialize(settings, onDidReceiveNotificationResponse: (details) {
  //     final message = RemoteMessage.fromMap(jsonDecode(details.payload ?? '{}'));
  //     handleMessage(message);
  //   });

  //   final platform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  //   await platform?.createNotificationChannelGroup(_simplePushNotificChannelGrp);
  //   await platform?.createNotificationChannel(_androidNotificChannel);
  //   // await platform?.createNotificationChannel(_backgroundHeadupChannel);
  // }

  Future<void> initFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
    final deviceToken = await _firebaseMessaging.getToken();
    print('Token: $deviceToken');
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotification();
    LocalNotificationsServic().initLocalNotifications(
      notificationChannelGroup: _simplePushNotificChannelGrp,
      androidNotificChannel: androidNotificChannel,
      handleMessage: handleMessage,
    );
    // initLocalNotifications();
  }
}

Future<void> testAllMethods() async {
  FirebaseMessaging.onMessage.listen((event) {
    print(event.ttl);
  });
}


// curl --header "Authorization: key=eCq1y4qgRpWpRcxE31CFA2:APA91bFbupkee1BTcjjVGqaBnq_kFq5nJB7d7YrImKPh07_QZrNHIC5m19DR-hBncyihJBPHw2tV2pIa-_RtKHu629y_7WbsalrUm0tvtqNmOf_eoU8zRmEdkyj0DHWkbCnNQDwwiRjR" --header Content-Type:"application/json" https://fcm.googleapis.com/fcm/send  -d //"{\\"to\\":\\"/topics/news\\",\\"notification\\": {\\"title\\": \\"Testing new message from Thunder client software\\",\\"text\\": \\"Here is the Sample message\\",\\"click_action\\":\\"OPEN_ACTIVITY_1\\"},\\"data\\": {\\"counter\\":\\"30\\",\\"duration_in\\":\\"s\\", \\"progress\\":\\"20\\",\\"max_progress\\":\\"50\\"}}"

// {"to":"/topics/news","notification": {"title": "Testing new message from Thunder client software","text": "Here is the Sample message","click_action":"OPEN_ACTIVITY_1"}, ,"data": {"counter":"30","duration_in":"s","progress":"20","max_progress":"50"}}