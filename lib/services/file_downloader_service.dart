import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'firebase_messaging_service.dart';
import 'local_notifications_service.dart';

class FileDownloaderService {
  static List<DownloadNotifications> notifications = [];

  void download({required String imageUrl}) async {
    // String fileName = 'image-${DateTime.now().millisecondsSinceEpoch}.deb';
    //cancel token instance
    final CancelToken cancelToken = CancelToken();
    //define notification id
    const int notificationId = 1;

    //save cancel token and notification id for handling cancel actions from notification
    notifications.add(DownloadNotifications(notificationId: notificationId, token: cancelToken));
    //current datetime as millisecepoch
    final String time = DateTime.now().millisecondsSinceEpoch.toString();
    //filename
    final String fileName = path.basename(Uri.parse(imageUrl).path) + time;
    //save to
    Directory directory = Directory('');
    //platform specific directory update
    if (Platform.isAndroid) {
      directory = (await getApplicationDocumentsDirectory());
    } else {
      directory = (await getDownloadsDirectory())!;
    }
    // dio init
    Dio dio = Dio();
    //download file
    try {
      dio.download(imageUrl, "${directory.path}/$fileName", cancelToken: cancelToken,
          onReceiveProgress: (count, total) {
        int progress = (count / total * 100).toInt();
        sleep(const Duration(seconds: 2));
        LocalNotificationsServic().showProgressInNotification(
            notificationId: notificationId,
            payload: {
              'type': 'custom',
              'notificationId': notificationId,
              'action': 'cancel_download',
            },
            message: RemoteMessage(
              notification: RemoteNotification(
                title: progress < 100 ? 'Downloading.....' : 'File Downloaded Successfully',
                body: fileName,
              ),
            ),
            progress: progress,
            actions: progress == 100 ? [] : null,
            androidNotificChannel: FirebaseMessagingService().androidNotificChannel);
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        print('Download Canceled!');
      } else {
        print(e.error);
        print(e.message);
        print(e.stackTrace);
      }
    }

    // String time = DateTime.now().microsecondsSinceEpoch.toString();

    // String fileName = path.basename(Uri.parse(imageUrl).path) + time;

    // Directory directory = await getTemporaryDirectory();
    // if (Platform.isAndroid) {
    //   directory = (await getApplicationDocumentsDirectory());
    // } else {
    //   directory = (await getDownloadsDirectory())!;
    // }

    // // print(fileName);
    // Dio dio = Dio();
    // CancelToken cancelToken = CancelToken();
// print(cancelToken.)
    // try {
    //   dio.download(imageUrl, "${directory.path}/$fileName", cancelToken: cancelToken,
    //       onReceiveProgress: (count, total) {
    //     int progress = (count / total * 100).toInt();
    //     sleep(const Duration(seconds: 2));
    //     LocalNotificationsServic().showProgressInNotification(
    //         notificationId: 1,
    //         payload: {
    //           'type': 'custom',
    //           'notificationId': 1,
    //           'action': 'cancel_download',
    //         },
    //         message: RemoteMessage(
    //           notification: RemoteNotification(
    //             title: progress < 100 ? 'Downloading.....' : 'File Downloaded Successfully',
    //             body: '${fileName.substring(0, 8)}...',
    //           ),
    //         ),
    //         progress: progress,
    //         androidNotificChannel: FirebaseMessagingService().androidNotificChannel);
    //   });
    // } on DioException catch (e) {
    //   print(e.error);
    //   print(e.message);
    //   print(e.stackTrace);
    // }
  }
}

class DownloadNotifications {
  final int notificationId;
  final CancelToken token;
  DownloadNotifications({
    required this.notificationId,
    required this.token,
  });
}
