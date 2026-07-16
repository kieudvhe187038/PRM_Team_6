/// Một tin nhắn trong hội thoại chat (khách hàng <-> shop).
class ChatMessage {
  final String text;
  final bool fromMe;
  final DateTime time;

  ChatMessage({required this.text, required this.fromMe, required this.time});

  /// Tạo từ JSON backend — người xem luôn là khách hàng nên [fromMe] chỉ
  /// đúng khi người gửi cũng là khách hàng.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderRole = json['senderRole'] ?? 'Customer';
    return ChatMessage(
      text: json['text'] ?? '',
      fromMe: senderRole == 'Customer',
      time:
          DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}
