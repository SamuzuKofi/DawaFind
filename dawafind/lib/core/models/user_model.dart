import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.requestedRole = 'patient',
  });

  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;

  /// The account type asked for at sign-up. Purely a record of the request:
  /// the granted role comes from which collection the uid is found in, so
  /// this never widens what the account can do. Accounts created before this
  /// field existed read back as 'patient'.
  final String requestedRole;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      requestedRole: data['requestedRole'] as String? ?? 'patient',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'requestedRole': requestedRole,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [uid, fullName, email, createdAt, requestedRole];
}
