import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/pharmacy_approval_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl({AdminRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AdminRemoteDataSource();

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<List<PharmacyApprovalEntity>> getPendingApprovals() => guard(
    () => _remoteDataSource.getPendingApprovals(),
    'Could not load pending pharmacies.',
  );

  @override
  Future<void> approvePharmacy(String pharmacyId) => guard(
    () => _remoteDataSource.approvePharmacy(pharmacyId),
    'Could not approve this pharmacy.',
  );

  @override
  Future<void> rejectPharmacy(String pharmacyId) => guard(
    () => _remoteDataSource.rejectPharmacy(pharmacyId),
    'Could not reject this pharmacy.',
  );
}
