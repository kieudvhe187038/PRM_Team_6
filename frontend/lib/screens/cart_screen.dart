import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'checkout_screen.dart';

/// Màn hình giỏ hàng: xem, đổi số lượng, xóa, đi đến thanh toán.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: cart.isEmpty
          ? Center(
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
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giỏ hàng đang trống',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = cart.items[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: kCardDecoration(radius: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatVnd(item.product.price),
                              style: const TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _RoundBtn(
                                  icon: Icons.remove,
                                  onTap: () => cart.decrease(item.product.id),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _RoundBtn(
                                  icon: Icons.add,
                                  onTap: () => cart.increase(item.product.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => cart.remove(item.product.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: kSoftShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          formatVnd(cart.totalPrice),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      ),
                      child: Text('Thanh toán (${cart.totalQuantity})'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kPrimaryDark),
      ),
    );
  }
}
