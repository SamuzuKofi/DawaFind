part of 'inventory_bloc.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventorySuccess extends InventoryState {
  InventorySuccess({required this.items});
  final List<dynamic> items;
}

class InventoryError extends InventoryState {
  InventoryError({required this.message});
  final String message;
}
