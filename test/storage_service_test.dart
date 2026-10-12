import 'dart:io';

import 'package:inventory_management_system/inventory_management.dart';
import 'package:test/test.dart';

void main() {
  test('creates and persists the JSON inventory file', () async {
    final directory = await Directory.systemTemp.createTemp('inventory_test');
    final file = File('${directory.path}/inventory.json');
    final storage = StorageService(file.path);
    final product = Product(
      id: 'p1',
      name: 'Mouse',
      description: '',
      categoryId: 'electronics',
      price: 15,
      quantity: 3,
      lowStockThreshold: 1,
    );

    expect(await storage.loadProducts(), isEmpty);
    await storage.saveProducts([product]);

    expect((await storage.loadProducts()).single, product);
    await directory.delete(recursive: true);
  });
}
