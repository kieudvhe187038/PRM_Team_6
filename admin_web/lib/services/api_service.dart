import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin_user.dart';
import '../models/chat_message.dart';
import '../models/dashboard_stats.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Lỗi trả về từ API (kèm thông báo để hiển thị cho người dùng).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Lớp gọi REST API tới backend .NET (BearShop.Api) — dùng chung 1 backend
/// với app khách hàng Flutter và trang BearShop.Admin (.NET MVC).
///
/// Base URL mặc định `http://localhost:5095/api`, có thể đổi lúc build bằng
/// `--dart-define=API_BASE_URL=http://may-chu:5095/api`.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// JWT token sau khi đăng nhập (gắn vào header Authorization).
  String? token;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5095/api',
  );

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

  // ----- DASHBOARD -----

  Future<DashboardStats> getDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) {
      throw ApiException('Không tải được số liệu thống kê.');
    }
    return DashboardStats.fromJson(jsonDecode(res.body));
  }

  // ----- PRODUCTS -----

  Future<List<Product>> getProducts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw ApiException('Không tải được danh sách sản phẩm.');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> createProduct(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Tạo sản phẩm thất bại.'));
    }
    return Product.fromJson(jsonDecode(res.body));
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Cập nhật sản phẩm thất bại.'));
    }
    return Product.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteProduct(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 204) {
      throw ApiException(_extractError(res, 'Xóa sản phẩm thất bại.'));
    }
  }

  // ----- ORDERS -----

  Future<List<Order>> getAllOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/all'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) {
      throw ApiException('Không tải được danh sách đơn hàng.');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> updateOrderStatus(int id, String status) async {
    final res = await http.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: _headers(auth: true),
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Cập nhật trạng thái thất bại.'));
    }
    return Order.fromJson(jsonDecode(res.body));
  }

  // ----- USERS -----

  Future<List<AdminUser>> getUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) {
      throw ApiException('Không tải được danh sách người dùng.');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => AdminUser.fromJson(e)).toList();
  }

  Future<void> setUserActive(int id, bool isActive) async {
    final res = await http.put(
      Uri.parse('$baseUrl/users/$id/status'),
      headers: _headers(auth: true),
      body: jsonEncode({'isActive': isActive}),
    );
    if (res.statusCode != 204) {
      throw ApiException(
        _extractError(res, 'Cập nhật trạng thái tài khoản thất bại.'),
      );
    }
  }

  // ----- CHAT -----

  Future<List<Conversation>> getConversations() async {
    final res = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) {
      throw ApiException('Không tải được danh sách hội thoại.');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Conversation.fromJson(e)).toList();
  }

  Future<List<ChatMessage>> getConversation(int customerId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/chat/$customerId'),
      headers: _headers(auth: true),
    );
    if (res.statusCode != 200) throw ApiException('Không tải được hội thoại.');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<void> sendToCustomer(int customerId, String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/$customerId'),
      headers: _headers(auth: true),
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 200) throw ApiException('Gửi tin nhắn thất bại.');
  }
}
