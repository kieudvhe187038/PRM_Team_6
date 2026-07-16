import 'package:intl/intl.dart';

/// Định dạng tiền tệ VND, ví dụ: 450000 -> "450.000đ".
final _currency = NumberFormat.decimalPattern('vi_VN');

String formatVnd(num value) => '${_currency.format(value)}đ';

/// Định dạng ngày giờ: 29/06/2026 14:30.
String formatDateTime(DateTime dt) => DateFormat('dd/MM/yyyy HH:mm').format(dt);
