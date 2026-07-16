import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// Màn hình trang chủ: danh sách sản phẩm gấu bông (tải từ backend .NET)
/// + lọc theo danh mục + tìm kiếm ngay tại chỗ (không chuyển trang).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'Tất cả';
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    // Tải sản phẩm từ API ngay khi mở trang chủ.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchCtrl.clear();
        _query = '';
      }
    });
  }

  void _openDetail(Product p) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
  }

  void _addToCart(Product p) {
    context.read<CartProvider>().add(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${p.name}" vào giỏ'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final productProvider = context.watch<ProductProvider>();
    final q = _query.trim().toLowerCase();
    // Khi đang tìm kiếm, bỏ qua bộ lọc danh mục và tìm trên toàn bộ sản phẩm
    // (chỉ cần tên sản phẩm chứa ký tự đã gõ).
    final filtered = q.isEmpty
        ? productProvider.byCategory(_category)
        : productProvider.products
              .where((p) => p.name.toLowerCase().contains(q))
              .toList();

    return Scaffold(
      body: Column(
        children: [
          // Header gradient: lời chào + tìm kiếm.
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _searching
                              ? Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchCtrl,
                                    autofocus: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    cursorColor: Colors.white,
                                    decoration: const InputDecoration(
                                      hintText: 'Tìm gấu bông...',
                                      hintStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      isDense: true,
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _query = v),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'BearShop 🧸',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Xin chào, ${user?.fullName ?? 'bạn'} 👋',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _searching ? Icons.close : Icons.search,
                              color: Colors.white,
                            ),
                            onPressed: _toggleSearch,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Thanh danh mục.
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kCategories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = kCategories[i];
                          final selected = cat == _category;
                          return ChoiceChip(
                            showCheckmark: false,
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: selected ? kPrimaryDark : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            selected: selected,
                            onSelected: (_) => setState(() => _category = cat),
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.18,
                            ),
                            selectedColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(
                                alpha: selected ? 0 : 0.6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (productProvider.offline)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Đang xem dữ liệu ngoại tuyến (không kết nối được máy chủ)',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(productProvider, filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider provider, List<Product> filtered) {
    if (provider.loading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_query.trim().isNotEmpty &&
        filtered.isEmpty &&
        provider.products.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Không tìm thấy "${_query.trim()}"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (provider.error != null && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
            const SizedBox(height: 8),
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => provider.load(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final p = filtered[i];
          return ProductCard(
            product: p,
            onTap: () => _openDetail(p),
            onAdd: () => _addToCart(p),
          );
        },
      ),
    );
  }
}
