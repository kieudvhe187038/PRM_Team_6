/// Sản phẩm gấu bông.
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
    required this.stock,
  });

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

  Map<String, dynamic> toUpsertJson() => {
    'name': name,
    'category': category,
    'price': price,
    'stock': stock,
    'imageUrl': imageUrl,
    'description': description,
  };
}

/// Danh mục sản phẩm gấu bông.
const List<String> kCategories = ['Gấu Teddy', 'Gấu nâu', 'Thú bông', 'Gấu mini'];
