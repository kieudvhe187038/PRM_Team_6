import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/app_theme.dart';
import 'chat_list_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'users_screen.dart';

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}

const _navItems = [
  _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Tổng quan'),
  _NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Sản phẩm'),
  _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Đơn hàng'),
  _NavItem(Icons.people_outline, Icons.people, 'Người dùng'),
  _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Tin nhắn'),
];

/// Khung chính của trang quản trị: sidebar điều hướng cố định bên trái +
/// nội dung bên phải.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    ProductsScreen(),
    OrdersScreen(),
    UsersScreen(),
    ChatListScreen(),
  ];

  Future<void> _logout() async {
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
    if (confirm != true || !mounted) return;

    context.read<AdminProvider>().clearLocal();
    context.read<ChatProvider>().clearLocal();
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
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
      body: Row(
        children: [
          _Sidebar(selectedIndex: _index, onSelect: (i) => setState(() => _index = i)),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: _navItems[_index].label,
                  adminName: user?.fullName ?? 'Admin',
                  onLogout: _logout,
                ),
                Expanded(
                  child: IndexedStack(index: _index, children: _pages),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _Sidebar({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: kBrandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🧸', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BearShop',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Trang quản trị',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final selected = i == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected ? kPrimary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSelect(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                selected ? item.selectedIcon : item.icon,
                                size: 20,
                                color: selected ? kPrimary : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? kPrimary : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String adminName;
  final VoidCallback onLogout;
  const _TopBar({required this.title, required this.adminName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: kSoftShadow),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          CircleAvatar(
            radius: 16,
            backgroundColor: kPrimary,
            child: Text(
              adminName.isNotEmpty ? adminName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Text(adminName, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Đăng xuất',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
