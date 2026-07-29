import 'package:flutter_bloc/flutter_bloc.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(InventoryInitial()) {
    on<InventoryLoaded>(_onLoaded);
    on<InventoryItemAdded>(_onItemAdded);
    on<InventoryItemDeleted>(_onItemDeleted);
  }

  Future<void> _onLoaded(
    InventoryLoaded event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    // call InventoryRepository.getItems()
  }

  Future<void> _onItemAdded(
    InventoryItemAdded event,
    Emitter<InventoryState> emit,
  ) async {
    //call InventoryRepository.addItem(event.item)
  }

  Future<void> _onItemDeleted(
    InventoryItemDeleted event,
    Emitter<InventoryState> emit,
  ) async {
    //call InventoryRepository.deleteItem(event.itemId)
  }
}
