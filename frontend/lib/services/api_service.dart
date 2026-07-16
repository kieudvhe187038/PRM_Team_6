import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Lỗi trả về từ API (kèm thông báo để hiển thị cho người dùng).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Lớp gọi REST API tới backend .NET (BearShop.Api).
///
/// - Trên Android Emulator, máy host được truy cập qua 10.0.2.2.
/// - Trên web/desktop/iOS simulator dùng localhost.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// JWT token sau khi đăng nhập (gắn vào header Authorization).
  String? token;

  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  static String get baseUrl => 'http://$_host:5095/api';

  Map<String, String> _headers({bool auth = false}) => {
    'Content-Type': 'application/json',
    if (auth && token != null) 'Authorization': 'Bearer $token',
  };

  /// Đọc thông báo lỗi từ body JSON ({"message": "..."}) nếu có.
  String _extractError(http.Response res, String fallback) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['message'] is String) return body['message'];
      if (body is Map && body['errors'] is Map) {
        final errors = (body['errors'] as Map).values.first;
        if (errors is List && errors.isNotEmpty) return errors.first.toString();
      }
    } catch (_) {}
    return fallback;
  }

  // ----- AUTH -----

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Đăng ký thất bại.'));
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Đăng nhập thất bại.'));
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ----- PRODUCTS -----

  Future<List<Product>> getProducts({String? category}) async {
    final uri = Uri.parse('$baseUrl/products').replace(
      queryParameters: (category != null && category != 'Tất cả')
          ? {'category': category}
          : null,
    );
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException('Không tải được danh sách sản phẩm.');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  // ----- ORDERS -----

  Future<List<Order>> getOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) {
      throw ApiException('Không tải được đơn hàng.');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> createOrder(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Đặt hàng thất bại.'));
    }
    return Order.fromJson(jsonDecode(res.body));
  }

  /// Hủy đơn chưa thanh toán (dùng khi thanh toán VNPay thất bại/bị hủy).
  Future<void> cancelOrder(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/orders/$id'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 204) {
      throw ApiException(_extractError(res, 'Hủy đơn thất bại.'));
    }
  }

  // ----- CHAT -----

  Future<List<ChatMessage>> getMyChat() async {
    final res = await http.get(
      Uri.parse('$baseUrl/chat/mine'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) throw ApiException('Không tải được hội thoại.');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<void> sendMyChat(String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/mine'),
      headers: _headers(auth: true),
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 200) throw ApiException('Gửi tin nhắn thất bại.');
  }

  // ----- PAYMENT -----

  Future<String> createVnPayUrl(int orderId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/payment/vnpay/create'),
      headers: _headers(auth: true),
      body: jsonEncode({'orderId': orderId}),
    );
    if (res.statusCode != 200) {
      throw ApiException(
        _extractError(res, 'Không tạo được liên kết thanh toán.'),
      );
    }
    return (jsonDecode(res.body) as Map<String, dynamic>)['paymentUrl']
        as String;
  }
}
