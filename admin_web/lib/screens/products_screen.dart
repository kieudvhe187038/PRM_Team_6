import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'product_form_dialog.dart';

/// Trang "Sản phẩm": bảng dữ liệu + thêm/sửa/xóa.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadProducts();
    });
  }

  Future<void> _delete(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Xóa sản phẩm "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final error = await context.read<AdminProvider>().deleteProduct(p.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final products = admin.products;

    if (admin.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => admin.loadProducts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: kCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Danh sách sản phẩm (${products.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => showProductFormDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm sản phẩm'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.grey))),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(kBg),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Ảnh')),
                      DataColumn(label: Text('Tên sản phẩm')),
                      DataColumn(label: Text('Danh mục')),
                      DataColumn(label: Text('Giá'), numeric: true),
                      DataColumn(label: Text('Tồn kho'), numeric: true),
                      DataColumn(label: Text('Đã bán'), numeric: true),
                      DataColumn(label: Text('')),
                    ],
                    rows: products.map((p) {
                      return DataRow(
                        cells: [
                          DataCell(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 40,
                                  height: 40,
                                  color: kBg,
                                  child: const Icon(Icons.image_not_supported_outlined, size: 18),
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(p.name)),
                          DataCell(Text(p.category)),
                          DataCell(Text(formatVnd(p.price))),
                          DataCell(Text('${p.stock}')),
                          DataCell(Text('${p.sold}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Sửa',
                                  onPressed: () => showProductFormDialog(context, product: p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  tooltip: 'Xóa',
                                  onPressed: () => _delete(p),
                                ),
                              ],
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
