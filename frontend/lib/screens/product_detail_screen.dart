import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'cart_screen.dart';

/// Màn hình chi tiết sản phẩm: ảnh lớn, mô tả, chọn số lượng, thêm vào giỏ.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Ảnh thật, kích thước lớn.
          Image.network(
            p.imageUrl,
            height: 320,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 320,
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (_, _, _) => Container(
              height: 320,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, size: 60),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: const BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: kCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatVnd(p.price),
                          style: const TextStyle(
                            fontSize: 24,
                            color: kPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, color: kAccent, size: 18),
                            Text(
                              ' ${p.rating}   ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Đã bán ${p.sold}   ',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Còn ${p.stock}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(p.category),
                          backgroundColor: kPrimary.withValues(alpha: 0.08),
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                            color: kPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: kCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.description,
                          style: const TextStyle(
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: kCardDecoration(),
                    child: Row(
                      children: [
                        const Text(
                          'Số lượng:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: () =>
                              setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_qty',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () => setState(
                            () => _qty = _qty < p.stock ? _qty + 1 : _qty,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: kSoftShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, color: kPrimary),
                  label: const Text(
                    'Thêm vào giỏ',
                    style: TextStyle(color: kPrimary),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().add(p, quantity: _qty);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().add(p, quantity: _qty);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: kPrimaryDark),
      ),
    );
  }
}
