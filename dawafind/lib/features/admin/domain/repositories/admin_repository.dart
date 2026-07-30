import '../entities/pharmacy_approval_entity.dart';

abstract class AdminRepository {
  Future<List<PharmacyApprovalEntity>> getPendingApprovals();

  Future<void> approvePharmacy(String pharmacyId);

  Future<void> rejectPharmacy(String pharmacyId);
}
