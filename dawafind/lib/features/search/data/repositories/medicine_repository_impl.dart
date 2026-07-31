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
  }) => guard(
    () => _remoteDataSource.search(
      query,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    ),
    'Search failed. Please try again.',
  );
}
