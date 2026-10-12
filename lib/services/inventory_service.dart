import 'dart:async';

import '../exceptions/inventory_exception.dart';
import '../models/product.dart';
import '../repositories/data_store.dart';

class StockChange {
  const StockChange({required this.product, required this.previousQuantity});

  final Product product;
  final int previousQuantity;
}

class InventoryService {
  InventoryService()
    : _products = DataStore<Product>(keyOf: (product) => product.id);

  final DataStore<Product> _products;
  final StreamController<StockChange> _stockChanges =
      StreamController<StockChange>.broadcast();

  List<Product> get products => _products.values;
  Stream<StockChange> get stockChanges => _stockChanges.stream;

  void addProduct(Product product) {
    if (_products.containsKey(product.id)) {
      throw InventoryException(
        'A product with id ${product.id} already exists.',
      );
    }
    _products.add(product);
  }

  Product removeProduct(String id) {
    final product = _products.remove(id);
    if (product == null) throw InventoryException('Product $id was not found.');
    return product;
  }

  Product updateProduct(Product updated) {
    if (!_products.containsKey(updated.id)) {
      throw InventoryException('Product ${updated.id} was not found.');
    }
    _products.add(updated);
    return updated;
  }

  Product increaseStock(String id, int amount) {
    _validateAmount(amount);
    return _changeStock(id, amount);
  }

  Product decreaseStock(String id, int amount) {
    _validateAmount(amount);
    final product = _find(id);
    if (amount > product.quantity) {
      throw InventoryException('Insufficient stock for ${product.name}.');
    }
    return _changeStock(id, -amount);
  }

  List<Product> search(String query) {
    final normalized = query.trim().toLowerCase();
    return products
        .where(
          (product) =>
              product.id.toLowerCase().contains(normalized) ||
              product.name.toLowerCase().contains(normalized),
        )
        .toList();
  }

  List<Product> filterByCategory(String categoryId) =>
      products.where((product) => product.categoryId == categoryId).toList();

  List<Product> get lowStockProducts =>
      products.where((product) => product.isLowStock).toList();

  Product? getProduct(String id) => _products.get(id);

  double get totalInventoryValue =>
      products.fold(0, (total, product) => total + product.totalValue);

  void replaceProducts(Iterable<Product> values) {
    _products.clear();
    for (final product in values) {
      _products.add(product);
    }
  }

  Future<void> dispose() => _stockChanges.close();

  Product _changeStock(String id, int change) {
    final current = _find(id);
    final updated = current.copyWith(quantity: current.quantity + change);
    _products.add(updated);
    _stockChanges.add(
      StockChange(product: updated, previousQuantity: current.quantity),
    );
    return updated;
  }

  Product _find(String id) {
    final product = _products.get(id);
    if (product == null) throw InventoryException('Product $id was not found.');
    return product;
  }

  void _validateAmount(int amount) {
    if (amount <= 0) throw InventoryException('Stock amount must be positive.');
  }
}
