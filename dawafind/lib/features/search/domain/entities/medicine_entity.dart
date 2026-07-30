import 'package:equatable/equatable.dart';

/// One row of a medicine search result: a Stock entry joined with its
/// Medicine and Pharmacy for display. Nothing in the UI needs a bare
/// Medicine or Stock in isolation, so this is a composite rather than a
/// 1:1 mirror of a single ERD entity.
class MedicineSearchResultEntity extends Equatable {
  const MedicineSearchResultEntity({
    required this.stockId,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.form,
    required this.packSize,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.price,
    required this.quantity,
    this.distanceKm,
  });

  final String stockId;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String form;
  final String packSize;
  final String pharmacyId;
  final String pharmacyName;
  final double price;
  final int quantity;
  final double? distanceKm;

  bool get inStock => quantity > 0;

  @override
  List<Object?> get props => [
    stockId,
    medicineId,
    medicineName,
    dosage,
    form,
    packSize,
    pharmacyId,
    pharmacyName,
    price,
    quantity,
    distanceKm,
  ];
}
