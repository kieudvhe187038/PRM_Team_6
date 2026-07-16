import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bearshop_admin/providers/auth_provider.dart';
import 'package:bearshop_admin/screens/login_screen.dart';
import 'package:bearshop_admin/utils/app_theme.dart';

void main() {
  testWidgets('Login screen shows email/password fields and validates empty submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(theme: buildAppTheme(), home: const LoginScreen()),
      ),
    );

    expect(find.text('Đăng nhập'), findsWidgets);

    // Xóa sẵn email demo rồi bấm đăng nhập -> phải báo lỗi validation, không gọi API.
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();

    expect(find.text('Vui lòng nhập email.'), findsOneWidget);
  });
}
