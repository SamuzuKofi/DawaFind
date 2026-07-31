import 'package:equatable/equatable.dart';

/// A pharmacy with its full stock list, for the pharmacy detail / map view
/// screens — a Pharmacy joined with every Stock+Medicine it carries.
class PharmacyDetailEntity extends Equatable {
  const PharmacyDetailEntity({
    required this.pharmacyId,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    required this.averageRating,
    required this.ratingCount,
    required this.stock,
  });

  final String pharmacyId;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> openingHours;
  final double averageRating;
  final int ratingCount;
  final List<PharmacyStockItemEntity> stock;

  @override
  List<Object?> get props => [
    pharmacyId,
    name,
    address,
    phone,
    latitude,
    longitude,
    openingHours,
    averageRating,
    ratingCount,
    stock,
  ];
}

class PharmacyStockItemEntity extends Equatable {
  const PharmacyStockItemEntity({
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.form,
    required this.packSize,
    required this.price,
    required this.quantity,
  });

  final String medicineId;
  final String medicineName;
  final String dosage;
  final String form;
  final String packSize;
  final double price;
  final int quantity;

  bool get inStock => quantity > 0;

  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    dosage,
    form,
    packSize,
    price,
    quantity,
  ];
}
