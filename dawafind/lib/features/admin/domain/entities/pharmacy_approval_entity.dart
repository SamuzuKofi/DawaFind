import 'package:equatable/equatable.dart';

/// A pharmacy awaiting (or already reviewed for) admin approval — a
/// display-shaped slice of the Pharmacy fields an admin actually needs to
/// see to make that call.
class PharmacyApprovalEntity extends Equatable {
  const PharmacyApprovalEntity({
    required this.pharmacyId,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
  });

  final String pharmacyId;
  final String name;
  final String address;
  final String phone;
  final String status; // 'pending' | 'approved' | 'rejected'

  @override
  List<Object?> get props => [pharmacyId, name, address, phone, status];
}
