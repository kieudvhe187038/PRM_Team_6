import 'package:flutter/material.dart';

import '../models/app_notification.dart';

/// Quản lý danh sách thông báo trong app.
class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _items = [
    AppNotification(
      title: 'Chào mừng đến BearShop! 🧸',
      body: 'Giảm 10% cho đơn hàng đầu tiên với mã WELCOME10.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.card_giftcard,
    ),
    AppNotification(
      title: 'Miễn phí vận chuyển',
      body: 'Freeship cho mọi đơn từ 300.000đ trong tháng này.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      icon: Icons.local_shipping,
    ),
  ];

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.read).length;

  /// Thêm thông báo mới (ví dụ khi đặt hàng thành công).
  void push(AppNotification n) {
    _items.insert(0, n);
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _items) {
      n.read = true;
    }
    notifyListeners();
  }
}
