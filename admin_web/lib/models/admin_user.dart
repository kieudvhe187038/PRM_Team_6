/// Thông tin người dùng hiển thị trong màn hình Quản lý người dùng.
class AdminUser {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final int orderCount;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.orderCount,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'],
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    role: json['role'] ?? 'Customer',
    isActive: json['isActive'] ?? true,
    orderCount: json['orderCount'] ?? 0,
  );
}
