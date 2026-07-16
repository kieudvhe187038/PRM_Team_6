/// Tập hợp các hàm validation dùng cho form (đăng nhập, sản phẩm).
///
/// Mỗi hàm trả về null khi hợp lệ, hoặc chuỗi thông báo lỗi khi không hợp lệ.
class Validators {
  static final _emailReg = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Email: bắt buộc và đúng định dạng.
  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Vui lòng nhập email.';
    if (!_emailReg.hasMatch(v)) return 'Email không đúng định dạng.';
    return null;
  }

  /// Trường bắt buộc chung.
  static String? required(String? value, String fieldName) {
    if ((value ?? '').trim().isEmpty) return 'Vui lòng nhập $fieldName.';
    return null;
  }
}
