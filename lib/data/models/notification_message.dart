import 'package:flutter/material.dart';

/// 消息通知模型
class NotificationMessage {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final IconData icon;
  final bool isRead;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    this.isRead = false,
  });

  NotificationMessage copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? time,
    IconData? icon,
    bool? isRead,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
    );
  }
}
