import 'package:inventory_management_system/inventory_management.dart';

Future<void> main() async {
  final service = InventoryService();
  final storage = StorageService('data/inventory.json');
  final monitor = StockMonitorService(service.stockChanges);
  final cli = InventoryCli(service, storage, monitor);
  await cli.run();
}
