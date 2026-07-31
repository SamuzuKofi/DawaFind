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
  Future<PharmacyDetailEntity> getPharmacyById(String pharmacyId) => guard(
    () => _remoteDataSource.getPharmacyById(pharmacyId),
    'Could not load this pharmacy.',
  );

  @override
  Future<List<PharmacySummaryEntity>> getNearbyPharmacies({
    double? userLatitude,
    double? userLongitude,
    int limit = 10,
  }) => guard(
    () => _remoteDataSource.getNearbyPharmacies(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      limit: limit,
    ),
    'Could not load nearby pharmacies.',
  );

  // A failed lookup here only decides whether a bookmark icon looks filled,
  // so it degrades to "not saved" rather than failing the whole screen.
  @override
  Future<bool> isPharmacySaved(String pharmacyId) async {
    try {
      return await _remoteDataSource.isPharmacySaved(pharmacyId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> savePharmacy(String pharmacyId) => guard(
    () => _remoteDataSource.savePharmacy(pharmacyId),
    'Could not save this pharmacy.',
  );

  @override
  Future<void> removePharmacy(String pharmacyId) => guard(
    () => _remoteDataSource.removePharmacy(pharmacyId),
    'Could not remove this pharmacy.',
  );

  @override
  Future<List<PharmacySummaryEntity>> getSavedPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) => guard(
    () => _remoteDataSource.getSavedPharmacies(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    ),
    'Could not load saved pharmacies.',
  );

  // Same reasoning as isPharmacySaved: this only preselects a star rating.
  @override
  Future<double?> getMyRating(String pharmacyId) async {
    try {
      return await _remoteDataSource.getMyRating(pharmacyId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> submitRating(String pharmacyId, double score) => guard(
    () => _remoteDataSource.submitRating(pharmacyId, score),
    'Could not submit your rating.',
  );

  @override
  Future<void> removeRating(String pharmacyId) => guard(
    () => _remoteDataSource.removeRating(pharmacyId),
    'Could not remove your rating.',
  );
}
