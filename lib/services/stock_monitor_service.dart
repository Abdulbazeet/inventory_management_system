import 'dart:async';

import 'inventory_service.dart';

class StockAlert {
  const StockAlert({required this.change});

  final StockChange change;
}

class StockMonitorService {
  StockMonitorService(Stream<StockChange> changes) {
    _subscription = changes.listen((change) {
      if (change.product.isLowStock) {
        _alerts.add(StockAlert(change: change));
      }
    });
  }

  late final StreamSubscription<StockChange> _subscription;
  final StreamController<StockAlert> _alerts =
      StreamController<StockAlert>.broadcast();

  Stream<StockAlert> get alerts => _alerts.stream;

  Future<void> dispose() async {
    await _subscription.cancel();
    await _alerts.close();
  }
}
