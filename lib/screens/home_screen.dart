import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simple_push_notification/services/file_downloader_service.dart';
import 'package:simple_push_notification/services/firebase_messaging_service.dart';
import 'package:simple_push_notification/services/local_notifications_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final String imageUrl =
      'https://w0.peakpx.com/wallpaper/83/677/HD-wallpaper-don-t-waste-your-time-success-english-quotes-inspirational-motivation-thumbnail.jpg';
  final String fileUrl =
      'https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.2.1.23/android-studio-2023.2.1.23-linux.tar.gz';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Home Screen'),
            actions: [
              IconButton(
                onPressed: () {
                  //todo download image logic here
                  FileDownloaderService().download(imageUrl: imageUrl);
                },
                icon: const Icon(Icons.file_download_outlined),
                color: Colors.green,
              ),
              IconButton(
                  onPressed: () {
                    LocalNotificationsServic().checkForFirebaseNotification();
                  },
                  icon: const Icon(Icons.notification_important_rounded)),
              IconButton(
                  onPressed: () {
                    LocalNotificationsServic().showCountDownInNotification(
                        message: const RemoteMessage(
                            notification: RemoteNotification(title: "Your class going to start...")),
                        duration: const Duration(minutes: 1, seconds: 3),
                        androidNotificChannel: FirebaseMessagingService().androidNotificChannel);
                  },
                  icon: const Icon(Icons.timer))
            ],
          ),
          body: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          )),
    );
  }
}
