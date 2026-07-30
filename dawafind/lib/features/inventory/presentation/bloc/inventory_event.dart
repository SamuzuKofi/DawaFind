part of 'inventory_bloc.dart';

abstract class InventoryEvent {}

class InventoryLoaded extends InventoryEvent {}

class InventoryItemAdded extends InventoryEvent {
  InventoryItemAdded({required this.item});
  final InventoryItemDraft item;
}

class InventoryItemUpdated extends InventoryEvent {
  InventoryItemUpdated({
    required this.stockId,
    required this.quantity,
    required this.price,
    required this.packSize,
  });
  final String stockId;
  final int quantity;
  final double price;
  final String packSize;
}

class InventoryItemDeleted extends InventoryEvent {
  InventoryItemDeleted({required this.itemId});
  final String itemId;
}
