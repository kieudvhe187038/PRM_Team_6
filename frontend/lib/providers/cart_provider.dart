import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Quản lý giỏ hàng (thêm / xóa / đổi số lượng).
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.lineTotal);

  bool get isEmpty => _items.isEmpty;

  /// Thêm sản phẩm vào giỏ; nếu đã có thì tăng số lượng.
  void add(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void increase(String productId) {
    final item = _items.firstWhere((i) => i.product.id == productId);
    item.quantity++;
    notifyListeners();
  }

  void decrease(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
