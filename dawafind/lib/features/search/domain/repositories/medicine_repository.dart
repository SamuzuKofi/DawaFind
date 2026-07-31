import '../entities/medicine_entity.dart';

abstract class MedicineRepository {
  Future<List<MedicineSearchResultEntity>> search(
    String query, {
    double? userLatitude,
    double? userLongitude,
  });
}
