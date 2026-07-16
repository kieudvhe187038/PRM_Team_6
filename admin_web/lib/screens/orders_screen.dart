import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';

/// Trang "Đơn hàng": bảng dữ liệu + đổi trạng thái.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOrders();
    });
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
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

  Color _orderBadgeColor(Order o) {
    if (o.status == OrderStatus.pending && o.paymentStatus == 'paid') {
      return Colors.teal;
    }
    return _statusColor(o.status);
  }

  Future<void> _changeStatus(Order order) async {
    final admin = context.read<AdminProvider>();
    final selected = await showModalBottomSheet<OrderStatus>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values
              .map(
                (s) => ListTile(
                  leading: Icon(Icons.circle, size: 12, color: _statusColor(s)),
                  title: Text(s.label),
                  trailing: order.status == s ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, s),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected == null || selected == order.status || !mounted) return;

    final error = await admin.updateOrderStatus(order.id, selected.name);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final orders = admin.orders;

    if (admin.loading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => admin.loadOrders(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: kCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danh sách đơn hàng (${orders.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Chưa có đơn hàng nào', style: TextStyle(color: Colors.grey))),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(kBg),
                    columnSpacing: 24,
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('Mã đơn')),
                      DataColumn(label: Text('Ngày đặt')),
                      DataColumn(label: Text('Người nhận')),
                      DataColumn(label: Text('Địa chỉ')),
                      DataColumn(label: Text('Thanh toán')),
                      DataColumn(label: Text('Trạng thái')),
                      DataColumn(label: Text('Tổng tiền'), numeric: true),
                    ],
                    rows: orders.map((o) {
                      return DataRow(
                        cells: [
                          DataCell(Text(o.code, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(formatDateTime(o.createdAt), style: const TextStyle(fontSize: 12))),
                          DataCell(Text(o.receiverName)),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(o.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          DataCell(Text(o.paymentMethod, style: const TextStyle(fontSize: 12))),
                          DataCell(
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _changeStatus(o),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _orderBadgeColor(o).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      o.displayStatusLabel,
                                      style: TextStyle(
                                        color: _orderBadgeColor(o),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(Icons.edit, size: 12, color: _orderBadgeColor(o)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              formatVnd(o.total),
                              style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
