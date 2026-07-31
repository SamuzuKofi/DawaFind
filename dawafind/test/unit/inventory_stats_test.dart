import 'package:dawafind/features/inventory/domain/entities/inventory_item_entity.dart';
import 'package:dawafind/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:dawafind/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

InventoryItemEntity _item(String name, int quantity) => InventoryItemEntity(
  stockId: 's-$name',
  medicineId: 'm-$name',
  medicineName: name,
  dosage: '500mg',
  form: 'Tablets',
  packSize: '20 tabs/pack',
  price: 800,
  quantity: quantity,
  lastUpdated: DateTime(2026, 1, 1),
);

class _FakeInventoryRepository implements InventoryRepository {
  @override
  Future<List<InventoryItemEntity>> getItems() async => [
    _item('Amoxicillin', 24),
    _item('Paracetamol', 3), // low but still in stock
    _item('Metformin', 0), // out of stock
  ];

  @override
  Future<void> addItem(InventoryItemDraft item) async {}

  @override
  Future<void> deleteItem(String stockId) async {}

  @override
  Future<void> updateItem({
    required String stockId,
    required int quantity,
    required double price,
    required String packSize,
  }) async {}
}

void main() {
  // The pharmacist dashboard derives its three overview cards from exactly
  // this list, replacing the hardcoded 124/98/26 placeholders.
  test('inventory items give the dashboard its stock counts', () async {
    final bloc = InventoryBloc(
      inventoryRepository: _FakeInventoryRepository(),
    );
    final states = <InventoryState>[];
    bloc.stream.listen(states.add);

    bloc.add(InventoryLoaded());
    await Future.delayed(const Duration(milliseconds: 50));

    expect(states.last, isA<InventorySuccess>());
    final items = (states.last as InventorySuccess).items;

    expect(items.length, 3, reason: 'Total Drugs');
    expect(items.where((i) => !i.isOutOfStock).length, 2, reason: 'In Stock');
    expect(items.where((i) => i.isOutOfStock).length, 1, reason: 'Out of Stock');

    // Low stock is tracked separately from out of stock: a pharmacy with 3
    // packs left still has them on the shelf.
    expect(items.where((i) => i.isLowStock).length, 1);

    await bloc.close();
  });
}
