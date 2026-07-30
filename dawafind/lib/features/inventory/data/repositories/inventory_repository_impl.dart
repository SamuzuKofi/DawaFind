import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({InventoryRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? InventoryRemoteDataSource();

  final InventoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<InventoryItemEntity>> getItems() async {
    try {
      return await _remoteDataSource.getItems();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not load your inventory.');
    }
  }

  @override
  Future<void> addItem(InventoryItemDraft item) async {
    try {
      await _remoteDataSource.addItem(item);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not add this medicine.');
    }
  }

  @override
  Future<void> updateItem({
    required String stockId,
    required int quantity,
    required double price,
    required String packSize,
  }) async {
    try {
      await _remoteDataSource.updateItem(
        stockId: stockId,
        quantity: quantity,
        price: price,
        packSize: packSize,
      );
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not update this item.');
    }
  }

  @override
  Future<void> deleteItem(String stockId) async {
    try {
      await _remoteDataSource.deleteItem(stockId);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not remove this item.');
    }
  }
}
