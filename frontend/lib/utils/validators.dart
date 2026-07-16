/// Tập hợp các hàm validation dùng cho form (đăng nhập, đăng ký, checkout).
///
/// Mỗi hàm trả về null khi hợp lệ, hoặc chuỗi thông báo lỗi khi không hợp lệ.
class Validators {
  static final _emailReg = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final _phoneReg = RegExp(r'^(0|\+84)\d{9}$');

  /// Họ tên: không trống, tối thiểu 2 ký tự.
  static String? fullName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Vui lòng nhập họ tên.';
    if (v.length < 2) return 'Họ tên quá ngắn.';
    return null;
  }

  /// Email: bắt buộc và đúng định dạng.
  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Vui lòng nhập email.';
    if (!_emailReg.hasMatch(v)) return 'Email không đúng định dạng.';
    return null;
  }

  /// Số điện thoại VN: 10 số bắt đầu bằng 0, hoặc +84 + 9 số.
  static String? phone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Vui lòng nhập số điện thoại.';
    if (!_phoneReg.hasMatch(v)) {
      return 'Số điện thoại không hợp lệ (VD: 0901234567).';
    }
    return null;
  }

  /// Mật khẩu: tối thiểu 6 ký tự, có cả chữ và số.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Mật khẩu phải gồm cả chữ và số.';
    }
    return null;
  }

  /// Xác nhận mật khẩu phải trùng khớp.
  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Vui lòng nhập lại mật khẩu.';
    if (value != original) return 'Mật khẩu nhập lại không khớp.';
    return null;
  }

  /// Trường bắt buộc chung (địa chỉ, tên người nhận...).
  static String? required(String? value, String fieldName) {
    if ((value ?? '').trim().isEmpty) return 'Vui lòng nhập $fieldName.';
    return null;
  }
}
