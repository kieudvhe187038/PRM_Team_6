import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';

/// Xem & trả lời hội thoại với 1 khách hàng cụ thể.
class ChatDetailScreen extends StatefulWidget {
  final int customerId;
  final String customerName;
  const ChatDetailScreen({super.key, required this.customerId, required this.customerName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _textCtrl = TextEditingController();
  Timer? _pollTimer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversation(widget.customerId);
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      context.read<ChatProvider>().loadConversation(widget.customerId);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await context.read<ChatProvider>().sendToCustomer(widget.customerId, text);
      _textCtrl.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi tin nhắn thất bại.')),
        );
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  Widget _bubble(ChatMessage m) {
    return Align(
      alignment: m.fromAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: m.fromAdmin ? kPrimary : const Color(0xFFF1F1F3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(m.fromAdmin ? 16 : 4),
            bottomRight: Radius.circular(m.fromAdmin ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text, style: TextStyle(color: m.fromAdmin ? Colors.white : const Color(0xFF2B2130))),
            const SizedBox(height: 4),
            Text(
              formatDateTime(m.time),
              style: TextStyle(fontSize: 11, color: m.fromAdmin ? Colors.white70 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatProvider>().messages;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2B2130),
        elevation: 0,
        title: Text(widget.customerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _bubble(messages[i]),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: kSoftShadow),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(hintText: 'Nhập tin nhắn trả lời...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
