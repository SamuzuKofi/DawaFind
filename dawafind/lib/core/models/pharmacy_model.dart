import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Pending until reviewed by an admin; approved pharmacies are the only
/// ones with isVisible true. Not yet reflected in the shared ERD diagram —
/// agreed with the team to add there once the admin approval flow lands.
enum PharmacyStatus { pending, approved, rejected }

PharmacyStatus _statusFromString(String? value) => PharmacyStatus.values
    .firstWhere((s) => s.name == value, orElse: () => PharmacyStatus.pending);

class PharmacyModel extends Equatable {
  const PharmacyModel({
    required this.pharmacyId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.openingHours,
    required this.averageRating,
    required this.ratingCount,
    required this.isVisible,
    required this.status,
  });

  final String pharmacyId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final Map<String, dynamic> openingHours;
  final double averageRating;
  final int ratingCount;
  final bool isVisible;
  final PharmacyStatus status;

  factory PharmacyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return PharmacyModel(
      pharmacyId: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      phone: data['phone'] as String? ?? '',
      openingHours: Map<String, dynamic>.from(
        data['openingHours'] as Map? ?? const {},
      ),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      isVisible: data['isVisible'] as bool? ?? false,
      status: _statusFromString(data['status'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
    'pharmacyId': pharmacyId,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'phone': phone,
    'openingHours': openingHours,
    'averageRating': averageRating,
    'ratingCount': ratingCount,
    'isVisible': isVisible,
    'status': status.name,
  };

  PharmacyModel copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    Map<String, dynamic>? openingHours,
    double? averageRating,
    int? ratingCount,
    bool? isVisible,
    PharmacyStatus? status,
  }) => PharmacyModel(
    pharmacyId: pharmacyId,
    name: name ?? this.name,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    phone: phone ?? this.phone,
    openingHours: openingHours ?? this.openingHours,
    averageRating: averageRating ?? this.averageRating,
    ratingCount: ratingCount ?? this.ratingCount,
    isVisible: isVisible ?? this.isVisible,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [
    pharmacyId,
    name,
    address,
    latitude,
    longitude,
    phone,
    openingHours,
    averageRating,
    ratingCount,
    isVisible,
    status,
  ];
}
