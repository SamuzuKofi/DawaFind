import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PharmacyStaffModel extends Equatable {
  const PharmacyStaffModel({
    required this.uid,
    required this.pharmacyId,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final String uid;
  final String pharmacyId;
  final String fullName;
  final String email;
  final DateTime createdAt;

  factory PharmacyStaffModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return PharmacyStaffModel(
      uid: doc.id,
      pharmacyId: data['pharmacyId'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'pharmacyId': pharmacyId,
    'fullName': fullName,
    'email': email,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [uid, pharmacyId, fullName, email, createdAt];
}
