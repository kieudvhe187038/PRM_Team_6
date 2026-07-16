import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';

/// Quản lý chat của Admin: danh sách hội thoại theo khách hàng + trả lời.
class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<ChatMessage> _messages = [];
  List<Conversation> _conversations = [];

  /// Khách hàng đang được xem hội thoại — dùng để loại bỏ phản hồi trễ
  /// (stale) của 1 khách khác khi Admin đã chuyển sang xem khách mới.
  int? _activeConversationCustomerId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Conversation> get conversations => List.unmodifiable(_conversations);

  void clearLocal() {
    _messages = [];
    _conversations = [];
    _activeConversationCustomerId = null;
    notifyListeners();
  }

  Future<void> loadConversations() async {
    try {
      _conversations = await _api.getConversations();
      notifyListeners();
    } catch (_) {
      // Giữ danh sách cũ nếu tải thất bại.
    }
  }

  Future<void> loadConversation(int customerId) async {
    _activeConversationCustomerId = customerId;
    try {
      final result = await _api.getConversation(customerId);
      if (_activeConversationCustomerId != customerId) return;
      _messages = result;
      notifyListeners();
    } catch (_) {
      // Giữ danh sách cũ nếu tải thất bại.
    }
  }

  Future<void> sendToCustomer(int customerId, String text) async {
    await _api.sendToCustomer(customerId, text);
    await loadConversation(customerId);
  }
}
