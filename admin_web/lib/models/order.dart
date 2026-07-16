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

/// Một dòng sản phẩm trong đơn hàng.
class OrderItem {
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productName: json['productName'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    quantity: json['quantity'] ?? 1,
  );
}

/// Một đơn hàng (góc nhìn quản lý — của mọi khách hàng).
class Order {
  final int id;
  final String code;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double total;
  final String receiverName;
  final String address;
  final String phone;
  final String paymentMethod;
  final String paymentStatus;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.receiverName,
    required this.address,
    required this.phone,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] ?? 0,
    code: json['code'] ?? json['id'].toString(),
    createdAt:
        DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ??
        DateTime.now(),
    items: (json['items'] as List? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: (json['total'] as num?)?.toDouble() ?? 0,
    receiverName: json['receiverName'] ?? '',
    address: json['address'] ?? '',
    phone: json['phone'] ?? '',
    paymentMethod: json['paymentMethod'] ?? '',
    paymentStatus: json['paymentStatus'] ?? 'unpaid',
    status: _statusFromString(json['status']),
  );

  /// Đơn chuyển khoản/VNPay đã thanh toán nhưng còn ở bước đầu thì hiện
  /// "Đã thanh toán" thay vì "Chờ xác nhận" (COD) để phân biệt rõ luồng.
  String get displayStatusLabel {
    if (status == OrderStatus.pending && paymentStatus == 'paid') {
      return 'Đã thanh toán';
    }
    return status.label;
  }
}
