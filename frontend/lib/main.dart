import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BearShopApp());
}

/// Ứng dụng bán gấu bông online — BearShop.
///
/// Áp dụng state management bằng Provider: AuthProvider, CartProvider,
/// OrderProvider, NotificationProvider.
class BearShopApp extends StatelessWidget {
  const BearShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'BearShop',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const _AppEntry(),
      ),
    );
  }
}

/// Quyết định màn hình đầu tiên: tự đăng nhập nếu còn phiên, ngược lại
/// hiển thị màn hình đăng nhập.
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Lấy provider trước khi await để không dùng context qua async gap.
    final auth = context.read<AuthProvider>();
    final orders = context.read<OrderProvider>();
    await auth.tryAutoLogin();
    // Tài khoản Admin không còn dùng app Flutter — quản lý qua trang web
    // BearShop.Admin — nên phiên đăng nhập cũ của Admin (nếu có) bị hủy.
    if (auth.isAdmin) {
      await auth.logout();
      return;
    }
    if (auth.isLoggedIn) {
      await orders.loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🧸', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: kPrimary),
                ],
              ),
            ),
          );
        }
        final auth = context.read<AuthProvider>();
        if (!auth.isLoggedIn) return const LoginScreen();
        return const MainShell();
      },
    );
  }
}
