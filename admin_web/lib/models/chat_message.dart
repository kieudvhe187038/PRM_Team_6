/// Một tin nhắn trong hội thoại chat (khách hàng <-> shop), góc nhìn Admin.
class ChatMessage {
  final String text;
  final bool fromAdmin;
  final DateTime time;

  const ChatMessage({
    required this.text,
    required this.fromAdmin,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] ?? '',
    fromAdmin: (json['senderRole'] ?? 'Customer') == 'Admin',
    time:
        DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ??
        DateTime.now(),
  );
}

/// Một hội thoại (theo khách hàng) hiển thị trong danh sách chat của Admin.
class Conversation {
  final int customerId;
  final String customerName;
  final String lastMessage;
  final DateTime lastMessageAt;

  const Conversation({
    required this.customerId,
    required this.customerName,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    customerId: json['customerId'],
    customerName: json['customerName'] ?? '',
    lastMessage: json['lastMessage'] ?? '',
    lastMessageAt:
        DateTime.tryParse(json['lastMessageAt'] ?? '')?.toLocal() ??
        DateTime.now(),
  );
}
