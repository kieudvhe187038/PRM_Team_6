import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/api_service.dart';

/// Quản lý đơn hàng — gọi backend .NET qua [ApiService].
class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  /// Tải lịch sử đơn hàng của user đang đăng nhập từ server.
  Future<void> loadOrders() async {
    try {
      _orders = await _api.getOrders();
    } catch (_) {
      _orders = [];
    }
    notifyListeners();
  }

  /// Tạo đơn hàng mới qua API và thêm vào đầu danh sách.
  Future<Order> placeOrder({
    required List<CartItem> items,
    required String receiverName,
    required String address,
    required String phone,
    required String paymentMethod,
  }) async {
    final body = {
      'receiverName': receiverName,
      'phone': phone,
      'address': address,
      'paymentMethod': paymentMethod,
      'items': items
          .map(
            (i) => {
              'productId': int.tryParse(i.product.id) ?? 0,
              'productName': i.product.name,
              'imageUrl': i.product.imageUrl,
              'price': i.product.price,
              'quantity': i.quantity,
            },
          )
          .toList(),
    };
    final order = await _api.createOrder(body);
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  /// Hủy đơn vừa tạo (thanh toán VNPay thất bại) — xóa khỏi CSDL lẫn danh sách local.
  Future<void> cancelOrder(int dbId) async {
    try {
      await _api.cancelOrder(dbId);
    } catch (_) {}
    _orders.removeWhere((o) => o.dbId == dbId);
    notifyListeners();
  }

  void clearLocal() {
    _orders = [];
    notifyListeners();
  }
}
