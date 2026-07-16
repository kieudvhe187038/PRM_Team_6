import 'package:flutter/material.dart';

/// Thông báo hiển thị trong màn hình Notifications.
class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    this.icon = Icons.notifications,
    this.read = false,
  });
}
