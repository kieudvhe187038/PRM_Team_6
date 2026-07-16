/// Mô hình dữ liệu cho một sản phẩm gấu bông.
///
/// Dùng `imageUrl` là ảnh thật (network image) để hiển thị trong app.
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int sold;
  final String imageUrl;
  final String description;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.sold,
    required this.imageUrl,
    required this.description,
    this.stock = 50,
  });

  /// Tạo Product từ JSON trả về bởi backend .NET.
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    sold: json['sold'] ?? 0,
    imageUrl: json['imageUrl'] ?? '',
    description: json['description'] ?? '',
    stock: json['stock'] ?? 0,
  );
}
