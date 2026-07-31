import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc({InventoryRepository? inventoryRepository})
    : _inventoryRepository = inventoryRepository ?? InventoryRepositoryImpl(),
      super(InventoryInitial()) {
    on<InventoryLoaded>(_onLoaded);
    on<InventoryItemAdded>(_onItemAdded);
    on<InventoryItemUpdated>(_onItemUpdated);
    on<InventoryItemDeleted>(_onItemDeleted);
  }

  final InventoryRepository _inventoryRepository;

  Future<void> _onLoaded(
    InventoryLoaded event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    await _reload(emit);
  }

  Future<void> _onItemAdded(
    InventoryItemAdded event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _inventoryRepository.addItem(event.item);
      await _reload(emit);
    } on AppException catch (e) {
      emit(InventoryError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(InventoryError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onItemUpdated(
    InventoryItemUpdated event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _inventoryRepository.updateItem(
        stockId: event.stockId,
        quantity: event.quantity,
        price: event.price,
        packSize: event.packSize,
      );
      await _reload(emit);
    } on AppException catch (e) {
      emit(InventoryError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(InventoryError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onItemDeleted(
    InventoryItemDeleted event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _inventoryRepository.deleteItem(event.itemId);
      await _reload(emit);
    } on AppException catch (e) {
      emit(InventoryError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(InventoryError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _reload(Emitter<InventoryState> emit) async {
    try {
      final items = await _inventoryRepository.getItems();
      emit(InventorySuccess(items: items));
    } on AppException catch (e) {
      emit(InventoryError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(InventoryError(message: 'Something went wrong. Please try again.'));
    }
  }
}
