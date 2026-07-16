import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import 'main_shell.dart';
import 'register_screen.dart';

/// Màn hình Đăng nhập — có validation đầy đủ cho email & mật khẩu.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'demo@bearshop.vn');
  final _passCtrl = TextEditingController(text: '123456');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Chỉ gọi đăng nhập khi mọi field hợp lệ.
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final error = await auth.login(_emailCtrl.text, _passCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }
    // Tài khoản Admin quản lý qua trang web BearShop.Admin, không dùng app này.
    if (auth.isAdmin) {
      await auth.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tài khoản quản lý vui lòng đăng nhập tại trang quản trị web.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await context.read<OrderProvider>().loadOrders();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBrandGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Text('🧸', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'BearShop',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Cửa hàng gấu bông online',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: kSoftShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            // Khi đăng nhập chỉ cần không trống là đủ để báo lỗi.
                            if ((v ?? '').isEmpty) {
                              return 'Vui lòng nhập mật khẩu.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Đăng nhập'),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Chưa có tài khoản?',
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                              child: const Text('Đăng ký ngay'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Tài khoản demo: demo@bearshop.vn / 123456',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
