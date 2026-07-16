/// Tài khoản người dùng đã đăng nhập.
class AppUser {
  final String fullName;
  final String email;
  final String phone;
  final String role;

  const AppUser({
    required this.fullName,
    required this.email,
    this.phone = '',
    this.role = 'Customer',
  });

  bool get isAdmin => role == 'Admin';
}
