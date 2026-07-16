import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_user.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';

/// Trang "Người dùng": danh sách + khóa/mở khóa tài khoản.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  Future<void> _toggleActive(AdminUser u) async {
    final action = u.isActive ? 'Khóa' : 'Mở khóa';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action tài khoản'),
        content: Text('$action tài khoản "${u.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final error = await context.read<AdminProvider>().setUserActive(u.id, !u.isActive);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final users = admin.users;

    if (admin.loading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => admin.loadUsers(),
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
                'Danh sách người dùng (${users.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (users.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Chưa có người dùng nào', style: TextStyle(color: Colors.grey))),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(kBg),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Họ tên')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Điện thoại')),
                      DataColumn(label: Text('Vai trò')),
                      DataColumn(label: Text('Số đơn'), numeric: true),
                      DataColumn(label: Text('Trạng thái')),
                      DataColumn(label: Text('')),
                    ],
                    rows: users.map((u) {
                      return DataRow(
                        cells: [
                          DataCell(Text(u.fullName)),
                          DataCell(Text(u.email)),
                          DataCell(Text(u.phone)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(u.role, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          DataCell(Text('${u.orderCount}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (u.isActive ? Colors.green : Colors.red).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                u.isActive ? 'Đang hoạt động' : 'Đã khóa',
                                style: TextStyle(
                                  color: u.isActive ? Colors.green.shade700 : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            u.role == 'Admin'
                                ? const SizedBox.shrink()
                                : TextButton(
                                    onPressed: () => _toggleActive(u),
                                    child: Text(u.isActive ? 'Khóa' : 'Mở khóa'),
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
