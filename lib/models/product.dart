import '../exceptions/inventory_exception.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.quantity,
    required this.lowStockThreshold,
  }) {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw InventoryException('Product id and name are required.');
    }
    if (price < 0) throw InventoryException('Price cannot be negative.');
    if (quantity < 0) throw InventoryException('Quantity cannot be negative.');
    if (lowStockThreshold < 0) {
      throw InventoryException('Low-stock threshold cannot be negative.');
    }
  }

  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double price;
  final int quantity;
  final int lowStockThreshold;

  bool get isLowStock => quantity <= lowStockThreshold;
  double get totalValue => price * quantity;

  Product copyWith({
    String? name,
    String? description,
    String? categoryId,
    double? price,
    int? quantity,
    int? lowStockThreshold,
  }) => Product(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    categoryId: json['categoryId'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'] as int,
    lowStockThreshold: json['lowStockThreshold'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categoryId': categoryId,
    'price': price,
    'quantity': quantity,
    'lowStockThreshold': lowStockThreshold,
  };

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
