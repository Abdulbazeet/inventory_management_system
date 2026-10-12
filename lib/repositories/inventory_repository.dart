import '../models/product.dart';

abstract interface class InventoryRepository {
  Future<List<Product>> loadProducts();

  Future<void> saveProducts(Iterable<Product> products);
}
