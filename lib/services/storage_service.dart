import 'dart:convert';
import 'dart:io';

import '../models/product.dart';
import '../repositories/inventory_repository.dart';

class StorageService implements InventoryRepository {
  const StorageService(this.filePath);

  final String filePath;

  @override
  Future<List<Product>> loadProducts() async {
    final file = File(filePath);
    if (!await file.exists()) {
      await _writeJson(file, const []);
      return [];
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final decoded = jsonDecode(content) as List<dynamic>;
    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveProducts(Iterable<Product> products) async {
    final file = File(filePath);
    await _writeJson(
      file,
      products.map((product) => product.toJson()).toList(),
    );
  }

  Future<void> _writeJson(File file, Object value) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(value));
  }
}
