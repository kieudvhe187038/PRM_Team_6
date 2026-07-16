import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

/// Tải và lưu danh sách sản phẩm từ backend .NET.
class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<Product> _products = [];
  bool _loading = false;
  String? _error;
  bool _offline = false;

  List<Product> get products => List.unmodifiable(_products);
  bool get loading => _loading;
  String? get error => _error;

  /// True khi danh sách đang hiển thị là dữ liệu cache (không kết nối được máy chủ).
  bool get offline => _offline;

  /// Tải toàn bộ sản phẩm (1 lần khi vào trang chủ).
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _api.getProducts();
      _offline = false;
      LocalDbService.instance.saveProducts(_products);
    } catch (_) {
      final cached = await LocalDbService.instance.getCachedProducts();
      if (cached.isNotEmpty) {
        _products = cached;
        _offline = true;
      } else {
        _offline = false;
        _error = 'Không kết nối được máy chủ.';
      }
    }
    _loading = false;
    notifyListeners();
  }

  /// Lọc theo danh mục ở phía client (đã có sẵn dữ liệu).
  List<Product> byCategory(String category) {
    if (category == 'Tất cả') return products;
    return _products.where((p) => p.category == category).toList();
  }

  /// Tìm kiếm theo tên/danh mục.
  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q),
        )
        .toList();
  }
}
