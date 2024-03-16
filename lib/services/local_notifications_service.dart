import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_push_notification/services/file_downloader_service.dart';
import 'package:simple_push_notification/services/firebase_messaging_service.dart';

class LocalNotificationsServic {
  final _localNotification = FlutterLocalNotificationsPlugin();

  Future initLocalNotifications({
    required notificationChannelGroup,
    required androidNotificChannel,
    required void Function(RemoteMessage?) handleMessage,
  }) async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotification.initialize(settings, onDidReceiveNotificationResponse: (details) {
      // final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
      final Map<String, dynamic> message = jsonDecode(details.payload!);
      // print(details.payload);
      if (message.containsKey('type') && message.containsKey('action')) {
        //todo handle conditions for notification pushed by app/ by developer
        //check is action == cancel Download
        print(message['action']);
        print(message['action'].runtimeType);
        switch (message['action']) {
          case 'cancel_download':
            cancelDownload(
              notificationId: message['notificationId'],
            );
            break;
        }
      } else {
        handleMessage(RemoteMessage.fromMap(message));
      }
    });

    final platform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannelGroup(notificationChannelGroup);
    await platform?.createNotificationChannel(androidNotificChannel);
    // await platform?.createNotificationChannel(_backgroundHeadupChannel);
  }

  showNotification({required RemoteMessage message, required androidNotificChannel, int? notificationId}) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotification.show(
      notificationId ?? notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(androidNotificChannel.id, androidNotificChannel.name,
            channelDescription: androidNotificChannel.description,
            visibility: NotificationVisibility.public,
            priority: Priority.max,
            importance: Importance.max,
            ticker: 'ticker',
            fullScreenIntent: true,
            onlyAlertOnce: true),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }

  showProgressInNotification(
      {Map<String, dynamic>? payload,
      required RemoteMessage message,
      int? notificationId,
      required int progress,
      int maxProgress = 100,
      List<AndroidNotificationAction>? actions,
      required androidNotificChannel}) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotification.show(
      notificationId ?? notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(androidNotificChannel.id, androidNotificChannel.name,
            channelDescription: androidNotificChannel.description,
            showProgress: progress < 100,
            progress: progress,
            maxProgress: maxProgress,
            onlyAlertOnce: true,
            visibility: NotificationVisibility.public,
            priority: Priority.max,
            importance: Importance.max,
            ticker: 'ticker',
            actions: actions ??
                [
                  const AndroidNotificationAction(
                    '0',
                    "Cancel Download",
                    cancelNotification: true,
                    showsUserInterface: true,
                  )
                ]),
      ),
      payload: jsonEncode(payload ?? message.toMap()),
    );
  }

  showCountDownInNotification(
      {required RemoteMessage message,
      required Duration duration,
      String? completionTitile,
      required androidNotificChannel}) {
    final notification = message.notification;
    if (notification == null) return;

    int timeElapsed = duration.inSeconds;
    String timeElapsedAsString = "";
    Timer.periodic(const Duration(seconds: 1), (timer) {
      int hours = timeElapsed ~/ (60 * 60);
      int minutes = (timeElapsed ~/ 60) % 60;
      int seconds = timeElapsed % 60;
      print(timeElapsed);
      print(timeElapsedAsString);
      if (timeElapsed <= 0) {
        timeElapsedAsString = "";
        timer.cancel();
      } else if (timeElapsed <= 5) {
        timeElapsedAsString = "only few seconds remaining";
      } else if (timeElapsed <= 60) {
        timeElapsedAsString = "$seconds seconds";
      } else {
        timeElapsedAsString = (hours <= 0 ? "" : "${hours}h ") +
            (minutes <= 0 ? "" : "${minutes}m ") +
            (seconds <= 0 ? "" : "${seconds}s ");
      }

      _localNotification.show(
        notification.hashCode,
        notification.title,
        timeElapsedAsString,
        NotificationDetails(
          android: AndroidNotificationDetails(androidNotificChannel.id, androidNotificChannel.name,
              channelDescription: androidNotificChannel.description,
              // showProgress: true,
              // progress: progress,
              // maxProgress: maxProgress,
              onlyAlertOnce: true,
              visibility: NotificationVisibility.public,
              priority: Priority.max,
              importance: Importance.max,
              ticker: 'ticker'),
        ),
        payload: jsonEncode(message.toMap()),
      );

      timeElapsed -= 1;
    });
  }

  Future<void> cancelNotification({required int notificationId}) async {
    await _localNotification.cancel(notificationId);
  }

  Future<void> cancelDownload({required int notificationId}) async {
    final notifications = FileDownloaderService.notifications;
    CancelToken? cancelToken;
    if (notifications.isNotEmpty) {
      //get cancel token - filter by notification id
      cancelToken = notifications.firstWhere((n) => n.notificationId == notificationId).token;
      //remove cancelling notification from notifiations list
      FileDownloaderService.notifications.removeWhere((n) => n.notificationId == notificationId);
    }
    //cancel download
    cancelToken?.cancel();
    //dismiss notification
    await _localNotification.cancel(notificationId);
  }

  Future<void> isNotificationsDismissed() async {
    final List<ActiveNotification> activeNotifications = await _localNotification.getActiveNotifications();

    final NotificationAppLaunchDetails? details = await _localNotification.getNotificationAppLaunchDetails();

    print(activeNotifications);
    for (var element in activeNotifications) {
      print("${element.channelId} --> ${element.id} ");
    }
  }

  Future<bool> checkForDismissedNotification() async {
    final NotificationAppLaunchDetails? details = await _localNotification.getNotificationAppLaunchDetails();
    FileDownloaderService.notifications.any((element) {
      if (element.notificationId == details?.notificationResponse?.id) {
        //remove notification form notfications list
        FileDownloaderService.notifications.remove(element);
        print("${element.notificationId} was removed - notification dismissed");
        return true;
      }
      return false;
    });
    return false;
  }

  Future<ActiveNotification?> checkForFirebaseNotification() async {
    final List<ActiveNotification> activeNotifications = await _localNotification.getActiveNotifications();

    // final NotificationAppLaunchDetails? details = await _localNotification.getNotificationAppLaunchDetails();

    print(activeNotifications);
    for (var element in activeNotifications) {
      print("${element.channelId} --> ${element.id} ${element.title}");
      if (element.title?.contains("from Backend") ?? false) {
        if (element.id != null) {
          //update notfication using local notfications plugin
          showNotification(
              message: RemoteMessage(
                notification: RemoteNotification(
                  title: element.title,
                  body: element.body,
                ),
              ),
              androidNotificChannel: FirebaseMessagingService().androidNotificChannel);
          _localNotification.cancel(element.id!);
        }
        checkForDismissedNotification();
        return element;
      }
    }
    return null;
  }
}
