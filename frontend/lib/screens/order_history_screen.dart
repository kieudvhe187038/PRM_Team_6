import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';

/// Màn hình lịch sử đơn hàng — đọc dữ liệu thật từ CSDL SQLite.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Tải lại từ server mỗi lần vào màn hình — tránh hiện paymentStatus cũ
    // (vd VNPay vừa thanh toán xong ở tab trình duyệt ngoài, backend đã cập
    // nhật "paid" nhưng đơn trong bộ nhớ app vẫn còn "unpaid" lúc tạo đơn).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  Color _statusColor(Order o) {
    if (o.status == OrderStatus.pending && o.paymentStatus == 'paid') {
      return Colors.teal;
    }
    switch (o.status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().loadOrders(),
        child: orders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: kPrimary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: kPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bạn chưa có đơn hàng nào',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final o = orders[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: kCardDecoration(radius: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              o.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(o).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                o.displayStatusLabel,
                                style: TextStyle(
                                  color: _statusColor(o),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(o.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(height: 18),
                        Text(
                          '${o.totalQuantity} sản phẩm • Giao tới: ${o.address}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              o.paymentMethod,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              formatVnd(o.total),
                              style: const TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
