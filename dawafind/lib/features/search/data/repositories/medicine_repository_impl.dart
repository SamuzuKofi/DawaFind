import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_datasource.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  MedicineRepositoryImpl({MedicineRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MedicineRemoteDataSource();

  final MedicineRemoteDataSource _remoteDataSource;

  @override
  Future<List<MedicineSearchResultEntity>> search(
    String query, {
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      return await _remoteDataSource.search(
        query,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Search failed. Please try again.');
    }
  }
}
