import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/pharmacy_model.dart';
import '../../domain/entities/pharmacy_approval_entity.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<PharmacyApprovalEntity>> getPendingApprovals() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.pharmacies)
        .where('status', isEqualTo: PharmacyStatus.pending.name)
        .get();
    return snapshot.docs.map((doc) {
      final pharmacy = PharmacyModel.fromFirestore(doc);
      return PharmacyApprovalEntity(
        pharmacyId: pharmacy.pharmacyId,
        name: pharmacy.name,
        address: pharmacy.address,
        phone: pharmacy.phone,
        status: pharmacy.status.name,
      );
    }).toList();
  }

  Future<void> approvePharmacy(String pharmacyId) async {
    await _firestore.collection(FirestorePaths.pharmacies).doc(pharmacyId).update({
      'status': PharmacyStatus.approved.name,
      'isVisible': true,
    });
  }

  Future<void> rejectPharmacy(String pharmacyId) async {
    await _firestore.collection(FirestorePaths.pharmacies).doc(pharmacyId).update({
      'status': PharmacyStatus.rejected.name,
      'isVisible': false,
    });
  }
}
