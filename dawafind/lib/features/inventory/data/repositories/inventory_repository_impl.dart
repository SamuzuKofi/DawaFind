import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({InventoryRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? InventoryRemoteDataSource();

  final InventoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<InventoryItemEntity>> getItems() =>
      guard(() => _remoteDataSource.getItems(), 'Could not load your inventory.');

  @override
  Future<void> addItem(InventoryItemDraft item) =>
      guard(() => _remoteDataSource.addItem(item), 'Could not add this medicine.');

  @override
  Future<void> updateItem({
    required String stockId,
    required int quantity,
    required double price,
    required String packSize,
  }) => guard(
    () => _remoteDataSource.updateItem(
      stockId: stockId,
      quantity: quantity,
      price: price,
      packSize: packSize,
    ),
    'Could not update this item.',
  );

  @override
  Future<void> deleteItem(String stockId) => guard(
    () => _remoteDataSource.deleteItem(stockId),
    'Could not remove this item.',
  );
}
