// Unit Test: kiểm thử các hàm validation của form.
import 'package:flutter_test/flutter_test.dart';
import 'package:online_sales_systems/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('email hợp lệ trả về null', () {
      expect(Validators.email('user@bearshop.vn'), isNull);
    });
    test('email sai định dạng trả về lỗi', () {
      expect(Validators.email('user-bearshop'), isNotNull);
    });
    test('email trống trả về lỗi', () {
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('mật khẩu có chữ và số, đủ dài là hợp lệ', () {
      expect(Validators.password('abc123'), isNull);
    });
    test('mật khẩu quá ngắn trả về lỗi', () {
      expect(Validators.password('a1'), isNotNull);
    });
    test('mật khẩu chỉ có chữ trả về lỗi', () {
      expect(Validators.password('abcdef'), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('số điện thoại VN hợp lệ', () {
      expect(Validators.phone('0901234567'), isNull);
    });
    test('số điện thoại sai trả về lỗi', () {
      expect(Validators.phone('12345'), isNotNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('khớp mật khẩu gốc là hợp lệ', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
    test('không khớp trả về lỗi', () {
      expect(Validators.confirmPassword('abc123', 'xyz789'), isNotNull);
    });
  });
}
