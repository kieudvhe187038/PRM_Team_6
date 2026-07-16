import 'package:flutter/foundation.dart';

import '../models/admin_user.dart';
import '../models/dashboard_stats.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// Quản lý state cho bộ màn hình Admin: sản phẩm, đơn hàng, người dùng,
/// thống kê tổng quan. Gọi backend .NET qua [ApiService].
class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<Product> _products = [];
  List<Order> _orders = [];
  List<AdminUser> _users = [];
  DashboardStats? _dashboard;
  bool _loading = false;

  List<Product> get products => List.unmodifiable(_products);
  List<Order> get orders => List.unmodifiable(_orders);
  List<AdminUser> get users => List.unmodifiable(_users);
  DashboardStats? get dashboard => _dashboard;
  bool get loading => _loading;

  void clearLocal() {
    _products = [];
    _orders = [];
    _users = [];
    _dashboard = null;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _loading = true;
    notifyListeners();
    try {
      _dashboard = await _api.getDashboard();
    } catch (_) {
      _dashboard = null;
    }
    _loading = false;
    notifyListeners();
  }

  // ----- Sản phẩm -----

  Future<void> loadProducts() async {
    _loading = true;
    notifyListeners();
    try {
      _products = await _api.getProducts();
    } catch (_) {
      _products = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> createProduct(Map<String, dynamic> body) async {
    try {
      final product = await _api.createProduct(body);
      _products = [..._products, product];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ.';
    }
  }

  Future<String?> updateProduct(String id, Map<String, dynamic> body) async {
    try {
      final updated = await _api.updateProduct(id, body);
      _products = _products.map((p) => p.id == id ? updated : p).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ.';
    }
  }

  Future<String?> deleteProduct(String id) async {
    try {
      await _api.deleteProduct(id);
      _products = _products.where((p) => p.id != id).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ.';
    }
  }

  // ----- Đơn hàng -----

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    try {
      _orders = await _api.getAllOrders();
    } catch (_) {
      _orders = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> updateOrderStatus(int dbId, String status) async {
    try {
      final updated = await _api.updateOrderStatus(dbId, status);
      final idx = _orders.indexWhere((o) => o.id == updated.id);
      if (idx != -1) {
        final next = [..._orders];
        next[idx] = updated;
        _orders = next;
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ.';
    }
  }

  // ----- Người dùng -----

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    try {
      _users = await _api.getUsers();
    } catch (_) {
      _users = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> setUserActive(int id, bool isActive) async {
    try {
      await _api.setUserActive(id, isActive);
      _users = await _api.getUsers();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ.';
    }
  }
}
