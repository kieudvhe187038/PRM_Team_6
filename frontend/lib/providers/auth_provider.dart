import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';

/// Quản lý đăng nhập / đăng ký — gọi backend .NET qua [ApiService].
///
/// JWT token và thông tin user được lưu trong SharedPreferences để tự
/// đăng nhập lại khi mở app.
class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Khôi phục phiên đăng nhập (token + thông tin user) khi mở lại app.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');
    if (token == null || email == null) return;
    _api.token = token;
    _user = AppUser(
      fullName: prefs.getString('fullName') ?? '',
      email: email,
      phone: prefs.getString('phone') ?? '',
      role: prefs.getString('role') ?? 'Customer',
    );
    notifyListeners();
  }

  /// Đăng nhập. Trả về null nếu thành công, hoặc chuỗi lỗi nếu thất bại.
  Future<String?> login(String email, String password) async {
    try {
      final data = await _api.login(email: email.trim(), password: password);
      await _applyAuth(data);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ. Kiểm tra backend đang chạy.';
    }
  }

  /// Đăng ký tài khoản mới.
  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final data = await _api.register(
        fullName: fullName,
        email: email.trim(),
        phone: phone,
        password: password,
      );
      await _applyAuth(data);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Không kết nối được máy chủ. Kiểm tra backend đang chạy.';
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  /// Lưu token + thông tin user trả về từ API.
  Future<void> _applyAuth(Map<String, dynamic> data) async {
    _api.token = data['token'];
    _user = AppUser(
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'Customer',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _user == null ? '' : data['token']);
    await prefs.setString('email', _user!.email);
    await prefs.setString('fullName', _user!.fullName);
    await prefs.setString('phone', _user!.phone);
    await prefs.setString('role', _user!.role);
    notifyListeners();
  }
}
