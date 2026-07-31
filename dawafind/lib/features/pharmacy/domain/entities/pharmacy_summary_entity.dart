import 'package:equatable/equatable.dart';

/// A pharmacy card for list contexts (saved pharmacies, nearby pharmacies)
/// — lighter than PharmacyDetailEntity since these views don't need the
/// full stock list.
class PharmacySummaryEntity extends Equatable {
  const PharmacySummaryEntity({
    required this.pharmacyId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.averageRating,
    this.distanceKm,
  });

  final String pharmacyId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double averageRating;
  final double? distanceKm;

  @override
  List<Object?> get props => [
    pharmacyId,
    name,
    address,
    latitude,
    longitude,
    averageRating,
    distanceKm,
  ];
}
