import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'chat_detail_screen.dart';

/// Trang "Tin nhắn": danh sách hội thoại theo khách hàng.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final conversations = chat.conversations;

    return RefreshIndicator(
      onRefresh: () => chat.loadConversations(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: kCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hội thoại với khách hàng (${conversations.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (conversations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: conversations.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = conversations[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: kPrimary.withValues(alpha: 0.12),
                        child: Text(
                          c.customerName.isNotEmpty ? c.customerName[0].toUpperCase() : '?',
                          style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(c.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        formatDateTime(c.lastMessageAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            customerId: c.customerId,
                            customerName: c.customerName,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
