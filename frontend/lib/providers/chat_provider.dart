import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';

/// Quản lý chat giữa khách hàng và shop.
class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Xóa toàn bộ dữ liệu cục bộ khi đăng xuất (tránh lộ hội thoại của
  /// phiên cũ nếu tài khoản khác đăng nhập sau đó trên cùng app).
  void clearLocal() {
    _messages = [];
    notifyListeners();
  }

  Future<void> loadMine() async {
    try {
      _messages = await _api.getMyChat();
      notifyListeners();
    } catch (_) {
      // Giữ danh sách cũ nếu tải thất bại (ví dụ mất mạng tạm thời khi poll).
    }
  }

  Future<void> sendMine(String text) async {
    await _api.sendMyChat(text);
    await loadMine();
  }
}
