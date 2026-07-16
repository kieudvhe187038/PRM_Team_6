import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

/// Cache sản phẩm cục bộ bằng SQLite để xem được khi mất mạng.
///
/// Chỉ hoạt động trên Android/iOS (nền tảng chính của đồ án) — `sqflite`
/// không hỗ trợ Web/Windows nếu không có `sqflite_common_ffi`, nên các
/// nền tảng đó sẽ bỏ qua cache (an toàn, chỉ mất tính năng xem offline).
class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Database? _db;

  Future<Database?> _open() async {
    if (!_supported) return null;
    if (_db != null) return _db;
    final path = join(await getDatabasesPath(), 'bearshop_cache.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE cached_products (
          id TEXT PRIMARY KEY,
          name TEXT, category TEXT, price REAL, rating REAL,
          sold INTEGER, imageUrl TEXT, description TEXT, stock INTEGER
        )
      '''),
    );
    return _db;
  }

  /// Lưu toàn bộ danh sách sản phẩm hiện tại (ghi đè cache cũ).
  Future<void> saveProducts(List<Product> products) async {
    final db = await _open();
    if (db == null) return;
    final batch = db.batch();
    batch.delete('cached_products');
    for (final p in products) {
      batch.insert('cached_products', {
        'id': p.id,
        'name': p.name,
        'category': p.category,
        'price': p.price,
        'rating': p.rating,
        'sold': p.sold,
        'imageUrl': p.imageUrl,
        'description': p.description,
        'stock': p.stock,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Đọc sản phẩm đã cache (rỗng nếu chưa từng lưu hoặc không hỗ trợ nền tảng).
  Future<List<Product>> getCachedProducts() async {
    final db = await _open();
    if (db == null) return [];
    final rows = await db.query('cached_products');
    return rows
        .map(
          (r) => Product(
            id: r['id'] as String,
            name: r['name'] as String,
            category: r['category'] as String,
            price: r['price'] as double,
            rating: r['rating'] as double,
            sold: r['sold'] as int,
            imageUrl: r['imageUrl'] as String,
            description: r['description'] as String,
            stock: r['stock'] as int,
          ),
        )
        .toList();
  }
}
