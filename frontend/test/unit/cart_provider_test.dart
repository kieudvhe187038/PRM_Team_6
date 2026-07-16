// Unit Test: kiểm thử logic nghiệp vụ của giỏ hàng (CartProvider).
import 'package:flutter_test/flutter_test.dart';
import 'package:online_sales_systems/models/product.dart';
import 'package:online_sales_systems/providers/cart_provider.dart';

void main() {
  const bear = Product(
    id: 'p01',
    name: 'Gấu Teddy trắng',
    category: 'Gấu Teddy',
    price: 100000,
    rating: 4.8,
    sold: 100,
    imageUrl: 'https://example.com/bear.jpg',
    description: 'mô tả',
  );

  group('CartProvider', () {
    test('thêm sản phẩm làm tăng số lượng và tổng tiền', () {
      final cart = CartProvider();
      cart.add(bear, quantity: 2);

      expect(cart.totalQuantity, 2);
      expect(cart.totalPrice, 200000);
      expect(cart.items.length, 1);
    });

    test('thêm cùng sản phẩm sẽ gộp số lượng, không tạo dòng mới', () {
      final cart = CartProvider();
      cart.add(bear);
      cart.add(bear);

      expect(cart.items.length, 1);
      expect(cart.totalQuantity, 2);
    });

    test('giảm số lượng tới 0 sẽ xóa sản phẩm khỏi giỏ', () {
      final cart = CartProvider();
      cart.add(bear);
      cart.decrease(bear.id);

      expect(cart.isEmpty, true);
      expect(cart.totalPrice, 0);
    });

    test('clear() làm rỗng giỏ hàng', () {
      final cart = CartProvider();
      cart.add(bear, quantity: 3);
      cart.clear();

      expect(cart.isEmpty, true);
      expect(cart.totalQuantity, 0);
    });
  });
}
