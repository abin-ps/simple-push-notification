import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notificationTitle,
    required this.notificationBody,
    required this.payload,
  });
  final String notificationTitle;
  final String notificationBody;
  final dynamic payload;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notificationTitle),
      subtitle: Text('$notificationBody \n Payload:\n${payload.toString()}'),
    );
  }
}
