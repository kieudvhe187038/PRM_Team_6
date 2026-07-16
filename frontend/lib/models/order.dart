import 'cart_item.dart';
import 'product.dart';

/// Trạng thái đơn hàng.
enum OrderStatus { pending, shipping, completed, cancelled }

OrderStatus _statusFromString(String? s) {
  switch (s) {
    case 'shipping':
      return OrderStatus.shipping;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.shipping:
        return 'Xác nhận';
      case OrderStatus.completed:
        return 'Giao thành công';
      case OrderStatus.cancelled:
        return 'Hủy đơn';
    }
  }
}

/// Một đơn hàng đã đặt.
class Order {
  final String id;

  /// Id số thật trong CSDL (dùng để gọi API thanh toán VNPay / hủy đơn).
  final int dbId;
  final DateTime createdAt;
  final List<CartItem> items;
  final double total;
  final String receiverName;
  final String address;
  final String phone;
  final String paymentMethod;

  /// Trạng thái thanh toán trả về từ backend: "unpaid" | "paid" | "failed".
  final String paymentStatus;
  OrderStatus status;

  Order({
    required this.id,
    required this.dbId,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.receiverName,
    required this.address,
    required this.phone,
    required this.paymentMethod,
    this.paymentStatus = 'unpaid',
    this.status = OrderStatus.pending,
  });

  /// Tạo Order từ JSON trả về bởi backend .NET.
  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List? ?? []);
    final items = rawItems.map((e) {
      final m = e as Map<String, dynamic>;
      return CartItem(
        product: Product(
          id: m['productId'].toString(),
          name: m['productName'] ?? '',
          category: '',
          price: (m['price'] as num?)?.toDouble() ?? 0,
          rating: 0,
          sold: 0,
          imageUrl: m['imageUrl'] ?? '',
          description: '',
        ),
        quantity: m['quantity'] ?? 1,
      );
    }).toList();

    return Order(
      id: json['code'] ?? json['id'].toString(),
      dbId: json['id'] ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ??
          DateTime.now(),
      items: items,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      receiverName: json['receiverName'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      status: _statusFromString(json['status']),
    );
  }

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Nhãn trạng thái để hiển thị: đơn chuyển khoản/VNPay đã thanh toán nhưng còn
  /// đang ở bước đầu thì hiện "Đã thanh toán" thay vì "Chờ xác nhận" (COD) để
  /// phân biệt rõ 2 luồng thanh toán khác nhau.
  String get displayStatusLabel {
    if (status == OrderStatus.pending && paymentStatus == 'paid') {
      return 'Đã thanh toán';
    }
    return status.label;
  }
}
