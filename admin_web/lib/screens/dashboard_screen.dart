import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';

/// Trang "Tổng quan": số liệu tổng, biểu đồ doanh thu 7 ngày, đơn theo
/// trạng thái, đơn gần đây, sản phẩm bán chạy.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
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

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: kCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final stats = admin.dashboard;

    if (admin.loading && stats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (stats == null) {
      return const Center(child: Text('Không tải được số liệu thống kê.'));
    }

    final maxRevenue = stats.revenueLast7Days.isEmpty
        ? 0.0
        : stats.revenueLast7Days.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: () => admin.loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _statCard('Doanh thu', formatVnd(stats.totalRevenue)),
                const SizedBox(width: 16),
                _statCard('Đơn hàng', '${stats.totalOrders}'),
                const SizedBox(width: 16),
                _statCard('Sản phẩm', '${stats.totalProducts}'),
                const SizedBox(width: 16),
                _statCard('Khách hàng', '${stats.totalCustomers}'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: kCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Doanh thu 7 ngày gần nhất',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: stats.revenueLast7Days.map((d) {
                              final heightPct = maxRevenue > 0 ? d.revenue / maxRevenue : 0.0;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        formatVnd(d.revenue),
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      FractionallySizedBox(
                                        heightFactor: heightPct.clamp(0.02, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: kPrimary,
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${d.date.day}/${d.date.month}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: kCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đơn hàng theo trạng thái',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (stats.ordersByStatus.isEmpty)
                          const Text('Chưa có đơn hàng.', style: TextStyle(color: Colors.grey))
                        else
                          ...stats.ordersByStatus.entries.map((e) {
                            final status = OrderStatus.values.firstWhere(
                              (s) => s.name == e.key,
                              orElse: () => OrderStatus.pending,
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, size: 10, color: _statusColor(status)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(status.label)),
                                  Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: kCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đơn hàng gần đây', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (stats.recentOrders.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Chưa có đơn hàng.', style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...stats.recentOrders.map(
                            (o) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(o.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(flex: 2, child: Text(o.receiverName)),
                                  Expanded(child: Text(o.displayStatusLabel)),
                                  Expanded(
                                    child: Text(
                                      formatVnd(o.total),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: kCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sản phẩm bán chạy', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (stats.topProducts.isEmpty)
                          const Text('Chưa có dữ liệu.', style: TextStyle(color: Colors.grey))
                        else
                          ...stats.topProducts.map(
                            (p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                                  Text('Đã bán ${p.sold}', style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
