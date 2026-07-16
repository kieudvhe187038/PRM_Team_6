import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Khung chính của app với BottomNavigationBar: Trang chủ, Giỏ hàng,
/// Thông báo, Tài khoản.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    CartScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalQuantity;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: kSoftShadow),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          indicatorColor: kPrimary.withValues(alpha: 0.15),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: kPrimary),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: _badge(const Icon(Icons.shopping_cart_outlined), cartCount),
              selectedIcon: _badge(
                const Icon(Icons.shopping_cart, color: kPrimary),
                cartCount,
              ),
              label: 'Giỏ hàng',
            ),
            NavigationDestination(
              icon: _badge(const Icon(Icons.notifications_outlined), unread),
              selectedIcon: _badge(
                const Icon(Icons.notifications, color: kPrimary),
                unread,
              ),
              label: 'Thông báo',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: kPrimary),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(Widget icon, int count) {
    if (count <= 0) return icon;
    return Badge(label: Text('$count'), backgroundColor: kPrimary, child: icon);
  }
}
