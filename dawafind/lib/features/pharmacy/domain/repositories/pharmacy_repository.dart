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

  /// The signed-in user's own rating for this pharmacy, if they've rated it.
  Future<double?> getMyRating(String pharmacyId);

  /// Creates or updates the signed-in user's rating and recomputes the
  /// pharmacy's averageRating/ratingCount atomically.
  Future<void> submitRating(String pharmacyId, double score);

  /// Deletes the signed-in user's rating and recomputes the aggregate.
  Future<void> removeRating(String pharmacyId);
}
