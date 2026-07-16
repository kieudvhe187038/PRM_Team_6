/// Tài khoản Admin đang đăng nhập.
class AppUser {
  final String fullName;
  final String email;
  final String role;

  const AppUser({
    required this.fullName,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'Admin';
}
