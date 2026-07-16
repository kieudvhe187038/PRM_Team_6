import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';

/// Màn hình thông báo của người dùng.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: provider.markAllRead,
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có thông báo',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = items[i];
                return Container(
                  decoration: kCardDecoration(radius: 14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: kPrimary.withValues(alpha: 0.12),
                      child: Icon(n.icon, color: kPrimary),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.read
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body),
                        const SizedBox(height: 2),
                        Text(
                          formatDateTime(n.time),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: n.read
                        ? null
                        : const Icon(Icons.circle, color: kPrimary, size: 10),
                  ),
                );
              },
            ),
    );
  }
}
