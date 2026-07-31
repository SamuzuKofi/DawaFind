import '../entities/inventory_item_entity.dart';

abstract class InventoryRepository {
  /// Every stock item belonging to the signed-in pharmacist's own pharmacy.
  Future<List<InventoryItemEntity>> getItems();

  Future<void> addItem(InventoryItemDraft item);

  Future<void> updateItem({
    required String stockId,
    required int quantity,
    required double price,
    required String packSize,
  });

  Future<void> deleteItem(String stockId);
}
