import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'store_map_screen.dart';

/// Màn hình tài khoản: thông tin user + các mục điều hướng + đăng xuất.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    context.read<OrderProvider>().clearLocal();
    context.read<ChatProvider>().clearLocal();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: kBg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          (user?.fullName.isNotEmpty ?? false)
                              ? user!.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            color: kPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if ((user?.phone ?? '').isNotEmpty)
                            Text(
                              user!.phone,
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: kCardDecoration(),
              child: Column(
                children: [
                  _tile(
                    context,
                    Icons.receipt_long,
                    'Đơn hàng của tôi',
                    const OrderHistoryScreen(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _tile(
                    context,
                    Icons.chat_bubble_outline,
                    'Chat với shop',
                    const ChatScreen(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _tile(
                    context,
                    Icons.location_on_outlined,
                    'Cửa hàng gần bạn',
                    const StoreMapScreen(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Container(
              decoration: kCardDecoration(),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _logout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
    );
  }
}
