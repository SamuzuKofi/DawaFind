import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/pharmacy_detail_entity.dart';
import '../../domain/entities/pharmacy_summary_entity.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_remote_datasource.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  PharmacyRepositoryImpl({PharmacyRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? PharmacyRemoteDataSource();

  final PharmacyRemoteDataSource _remoteDataSource;

  @override
  Future<PharmacyDetailEntity> getPharmacyById(String pharmacyId) async {
    try {
      return await _remoteDataSource.getPharmacyById(pharmacyId);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not load this pharmacy.');
    }
  }

  @override
  Future<bool> isPharmacySaved(String pharmacyId) async {
    try {
      return await _remoteDataSource.isPharmacySaved(pharmacyId);
    } on FirebaseException {
      return false;
    }
  }

  @override
  Future<void> savePharmacy(String pharmacyId) async {
    try {
      await _remoteDataSource.savePharmacy(pharmacyId);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not save this pharmacy.');
    }
  }

  @override
  Future<void> removePharmacy(String pharmacyId) async {
    try {
      await _remoteDataSource.removePharmacy(pharmacyId);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not remove this pharmacy.');
    }
  }

  @override
  Future<List<PharmacySummaryEntity>> getSavedPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      return await _remoteDataSource.getSavedPharmacies(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not load saved pharmacies.');
    }
  }
}
