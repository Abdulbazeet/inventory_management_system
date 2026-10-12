import 'package:inventory_management_system/inventory_management.dart';
import 'package:test/test.dart';

Product makeProduct({int quantity = 5}) => Product(
  id: 'p1',
  name: 'Keyboard',
  description: '',
  categoryId: 'electronics',
  price: 10,
  quantity: quantity,
  lowStockThreshold: 2,
);

void main() {
  test('adds, searches, filters, and calculates inventory value', () async {
    final service = InventoryService();
    service.addProduct(makeProduct());

    expect(service.search('key').single.id, 'p1');
    expect(service.filterByCategory('electronics'), hasLength(1));
    expect(service.totalInventoryValue, 50);
    await service.dispose();
  });

  test('prevents duplicates and insufficient stock', () async {
    final service = InventoryService();
    service.addProduct(makeProduct());

    expect(
      () => service.addProduct(makeProduct()),
      throwsA(isA<InventoryException>()),
    );
    expect(
      () => service.decreaseStock('p1', 6),
      throwsA(isA<InventoryException>()),
    );
    await service.dispose();
  });

  test('monitor receives a low-stock event after a stock decrease', () async {
    final service = InventoryService();
    final monitor = StockMonitorService(service.stockChanges);
    final alertFuture = monitor.alerts.first;
    service.addProduct(makeProduct());
    service.decreaseStock('p1', 4);

    expect((await alertFuture).change.product.quantity, 1);
    await monitor.dispose();
    await service.dispose();
  });
}
