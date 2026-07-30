import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [uid, fullName, email, createdAt];
}
