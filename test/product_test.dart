import 'package:inventory_management_system/inventory_management.dart';
import 'package:test/test.dart';

void main() {
  test('serializes and deserializes a product', () {
    final product = Product(
      id: 'p1',
      name: 'Keyboard',
      description: 'Mechanical keyboard',
      categoryId: 'electronics',
      price: 49.99,
      quantity: 4,
      lowStockThreshold: 2,
    );

    expect(Product.fromJson(product.toJson()), product);
    expect(product.totalValue, closeTo(199.96, 0.001));
  });

  test('rejects negative prices and quantities', () {
    expect(
      () => Product(
        id: 'p1',
        name: 'Keyboard',
        description: '',
        categoryId: 'electronics',
        price: -1,
        quantity: 1,
        lowStockThreshold: 0,
      ),
      throwsA(isA<InventoryException>()),
    );
  });
}
