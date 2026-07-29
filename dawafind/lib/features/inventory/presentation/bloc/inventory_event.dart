part of 'inventory_bloc.dart';

abstract class InventoryEvent {}

class InventoryLoaded extends InventoryEvent {}

class InventoryItemAdded extends InventoryEvent {
  InventoryItemAdded({required this.item});
  final dynamic item;
}

class InventoryItemDeleted extends InventoryEvent {
  InventoryItemDeleted({required this.itemId});
  final String itemId;
}
