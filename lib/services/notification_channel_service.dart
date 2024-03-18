import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationChannelService {
  static const MethodChannel _channel =
      MethodChannel('simplepushnotification.com/fcm_simple_push_notification_channel');

  Map<String, String> channelMap = {
    "id": "CHAT_MESSAGES",
    "name": "Chats",
    "description": "Chat notifications",
  };

  Future<void> initNotificationChannel() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    //check for notification channel exist or not
    bool isChannelExist = sp.getBool('SIMPLE_PUSH_NOTIFICATION_CHANNEL') ?? false;
    if (!isChannelExist) {
      // create channel
      try {
        await _channel.invokeMethod('createNotificationChannel', channelMap);
        sp.setBool('SIMPLE_PUSH_NOTIFICATION_CHANNEL', true);
        print('notification channel created.');
      } on PlatformException catch (e) {
        print('============\$WARNING\$============');
        print('Failed to create channel!');
        print(e);
        print('============\$WARNING\$============');
      }
    } else {
      print('channel already exist.');
    }
  }
}
