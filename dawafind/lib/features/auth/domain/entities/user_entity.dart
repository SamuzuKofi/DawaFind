import 'package:equatable/equatable.dart';

/// Pure domain object for the signed-in account. Distinct from UserModel:
/// role/pharmacyId aren't stored on the users/{uid} doc itself — they're
/// derived from *which* collection (users vs pharmacyStaff) the uid was
/// found in.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.pharmacyId,
  });

  final String uid;
  final String fullName;
  final String email;
  final String role; // 'patient' | 'pharmacist' | 'admin'
  final String? pharmacyId; // set only when role == 'pharmacist'

  @override
  List<Object?> get props => [uid, fullName, email, role, pharmacyId];
}
