import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/admin_shell.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BearShopAdminApp());
}

/// Trang quản trị BearShop — Flutter Web độc lập, gọi cùng backend .NET
/// (`BearShop.Api`) với app khách hàng, dành riêng cho tài khoản Admin.
class BearShopAdminApp extends StatelessWidget {
  const BearShopAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'BearShop Admin',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const _AppEntry(),
      ),
    );
  }
}

/// Tự đăng nhập nếu còn phiên hợp lệ, ngược lại hiển thị màn đăng nhập.
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
    _init = context.read<AuthProvider>().tryAutoLogin();
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
        return auth.isLoggedIn ? const AdminShell() : const LoginScreen();
      },
    );
  }
}
