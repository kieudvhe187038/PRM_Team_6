// Widget Test: kiểm thử giao diện màn hình đăng nhập + validation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:online_sales_systems/providers/auth_provider.dart';
import 'package:online_sales_systems/providers/cart_provider.dart';
import 'package:online_sales_systems/providers/notification_provider.dart';
import 'package:online_sales_systems/providers/order_provider.dart';
import 'package:online_sales_systems/providers/product_provider.dart';
import 'package:online_sales_systems/screens/login_screen.dart';
import 'package:online_sales_systems/utils/app_theme.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ],
    child: MaterialApp(theme: buildAppTheme(), home: child),
  );
}

void main() {
  testWidgets('Màn hình đăng nhập hiển thị đầy đủ thành phần',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    expect(find.text('BearShop'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Báo lỗi khi email sai định dạng',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    // Nhập email sai và mật khẩu trống rồi bấm đăng nhập.
    await tester.enterText(
        find.byType(TextFormField).first, 'email-khong-hop-le');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();

    expect(find.text('Email không đúng định dạng.'), findsOneWidget);
  });
}
