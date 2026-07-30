import '../entities/pharmacy_detail_entity.dart';
import '../entities/pharmacy_summary_entity.dart';

abstract class PharmacyRepository {
  Future<PharmacyDetailEntity> getPharmacyById(String pharmacyId);

  Future<bool> isPharmacySaved(String pharmacyId);

  Future<void> savePharmacy(String pharmacyId);

  Future<void> removePharmacy(String pharmacyId);

  Future<List<PharmacySummaryEntity>> getSavedPharmacies({
    double? userLatitude,
    double? userLongitude,
  });
}
