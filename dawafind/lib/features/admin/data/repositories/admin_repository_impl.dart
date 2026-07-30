import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/pharmacy_approval_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl({AdminRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AdminRemoteDataSource();

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<List<PharmacyApprovalEntity>> getPendingApprovals() async {
    try {
      return await _remoteDataSource.getPendingApprovals();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not load pending pharmacies.');
    }
  }

  @override
  Future<void> approvePharmacy(String pharmacyId) async {
    try {
      await _remoteDataSource.approvePharmacy(pharmacyId);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not approve this pharmacy.');
    }
  }

  @override
  Future<void> rejectPharmacy(String pharmacyId) async {
    try {
      await _remoteDataSource.rejectPharmacy(pharmacyId);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not reject this pharmacy.');
    }
  }
}
