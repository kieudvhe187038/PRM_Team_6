import 'package:flutter/material.dart';

import '../models/order.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'main_shell.dart';
import 'order_history_screen.dart';

/// Màn hình xác nhận đặt hàng thành công.
class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  /// true khi chưa xác nhận được thanh toán VNPay (mở bằng trình duyệt
  /// ngoài) — đơn đã tạo nhưng còn chờ khách hoàn tất thanh toán.
  final bool paymentPending;
  const OrderSuccessScreen({
    super.key,
    required this.order,
    this.paymentPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = paymentPending ? Colors.orange : Colors.green;
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  paymentPending ? Icons.hourglass_top : Icons.check_circle,
                  color: color,
                  size: 84,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                paymentPending
                    ? 'Đơn hàng đã được tạo!'
                    : 'Đặt hàng thành công!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã đơn: ${order.id}',
                style: const TextStyle(color: Colors.grey),
              ),
              if (paymentPending) ...[
                const SizedBox(height: 8),
                const Text(
                  'Vui lòng hoàn tất thanh toán VNPay trên trình duyệt vừa mở. '
                  'Trạng thái đơn sẽ tự động cập nhật sau khi thanh toán xong.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: kCardDecoration(),
                child: Column(
                  children: [
                    _row('Người nhận', order.receiverName),
                    _row('Địa chỉ', order.address),
                    _row('SĐT', order.phone),
                    _row('Thanh toán', order.paymentMethod),
                    const Divider(height: 20),
                    _row('Tổng tiền', formatVnd(order.total), bold: true),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                ),
                child: const Text('Xem đơn hàng của tôi'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (route) => false,
                ),
                child: const Text('Tiếp tục mua sắm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? kPrimary : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
