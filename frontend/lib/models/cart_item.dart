import 'product.dart';

/// Một dòng trong giỏ hàng: sản phẩm + số lượng.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Thành tiền của dòng này = giá * số lượng.
  double get lineTotal => product.price * quantity;
}
