import 'dart:async';
import 'dart:io';

import '../exceptions/inventory_exception.dart';
import '../models/product.dart';
import '../repositories/inventory_repository.dart';
import '../services/inventory_service.dart';
import '../services/stock_monitor_service.dart';
import '../utils/input_helpers.dart';

class InventoryCli {
  InventoryCli(this.inventory, this.repository, this.monitor);

  final InventoryService inventory;
  final InventoryRepository repository;
  final StockMonitorService monitor;

  Future<void> run() async {
    try {
      await _load();
      final alertSubscription = monitor.alerts.listen(_displayAlert);
      await _menuLoop();
      await alertSubscription.cancel();
    } finally {
      await monitor.dispose();
      await inventory.dispose();
    }
  }

  Future<void> _menuLoop() async {
    var running = true;
    while (running) {
      _displayMenu();
      final choice = InputHelpers.readRequired('Choose an option');
      try {
        switch (choice) {
          case '1':
            await _addProduct();
          case '2':
            await _removeProduct();
          case '3':
            await _updateProduct();
          case '4':
            await _changeStock(increase: true);
          case '5':
            await _changeStock(increase: false);
          case '6':
            _displayProducts(
              inventory.search(
                InputHelpers.readRequired('Search by id or name'),
              ),
            );
          case '7':
            _displayProducts(
              inventory.filterByCategory(
                InputHelpers.readRequired('Category id'),
              ),
            );
          case '8':
            _displayProducts(inventory.products);
          case '9':
            _displayProducts(inventory.lowStockProducts);
          case '10':
            stdout.writeln(
              'Total inventory value: ${inventory.totalInventoryValue.toStringAsFixed(2)}',
            );
          case '0':
            running = false;
          default:
            stdout.writeln('Invalid option. Choose a number from 0 to 10.');
        }
      } on InventoryException catch (error) {
        stdout.writeln('Error: $error');
      } on FormatException catch (error) {
        stdout.writeln('Input error: ${error.message}');
      } on IOException catch (error) {
        stdout.writeln('Storage error: $error');
      }
    }
  }

  Future<void> _addProduct() async {
    final product = Product(
      id: InputHelpers.readRequired('Product id'),
      name: InputHelpers.readRequired('Name'),
      description: InputHelpers.readOptional('Description'),
      categoryId: InputHelpers.readRequired('Category id'),
      price: InputHelpers.readDouble('Price'),
      quantity: InputHelpers.readInt('Quantity'),
      lowStockThreshold: InputHelpers.readInt('Low-stock threshold'),
    );
    inventory.addProduct(product);
    await _save();
    stdout.writeln('Product added.');
  }

  Future<void> _removeProduct() async {
    final product = inventory.removeProduct(
      InputHelpers.readRequired('Product id'),
    );
    await _save();
    stdout.writeln('${product.name} removed.');
  }

  Future<void> _updateProduct() async {
    final id = InputHelpers.readRequired('Product id');
    final current = inventory.getProduct(id);
    if (current == null) {
      throw InventoryException('Product $id was not found.');
    }
    final updated = current.copyWith(
      name: InputHelpers.readRequired('Name'),
      description: InputHelpers.readOptional('Description'),
      categoryId: InputHelpers.readRequired('Category id'),
      price: InputHelpers.readDouble('Price'),
      lowStockThreshold: InputHelpers.readInt('Low-stock threshold'),
    );
    inventory.updateProduct(updated);
    await _save();
    stdout.writeln('Product updated.');
  }

  Future<void> _changeStock({required bool increase}) async {
    final id = InputHelpers.readRequired('Product id');
    final amount = InputHelpers.readInt('Quantity', minimum: 1);
    if (increase) {
      inventory.increaseStock(id, amount);
    } else {
      inventory.decreaseStock(id, amount);
    }
    await _save();
    stdout.writeln('Stock updated.');
  }

  Future<void> _load() async =>
      inventory.replaceProducts(await repository.loadProducts());

  Future<void> _save() => repository.saveProducts(inventory.products);

  void _displayMenu() {
    stdout.writeln('\nInventory Management System');
    stdout.writeln('1. Add product');
    stdout.writeln('2. Remove product');
    stdout.writeln('3. Update product');
    stdout.writeln('4. Increase stock');
    stdout.writeln('5. Decrease stock');
    stdout.writeln('6. Search by id or name');
    stdout.writeln('7. Filter by category');
    stdout.writeln('8. List all products');
    stdout.writeln('9. Display low-stock products');
    stdout.writeln('10. Show total inventory value');
    stdout.writeln('0. Exit');
  }

  void _displayProducts(Iterable<Product> products) {
    final items = products.toList();
    if (items.isEmpty) {
      stdout.writeln('No products found.');
      return;
    }
    stdout.writeln('ID | Name | Category | Price | Quantity | Value');
    for (final product in items) {
      stdout.writeln(
        '${product.id} | ${product.name} | ${product.categoryId} | '
        '${product.price.toStringAsFixed(2)} | ${product.quantity} | '
        '${product.totalValue.toStringAsFixed(2)}',
      );
    }
  }

  void _displayAlert(StockAlert alert) {
    final product = alert.change.product;
    stdout.writeln(
      'LOW STOCK ALERT: ${product.name} has ${product.quantity} remaining.',
    );
  }
}
