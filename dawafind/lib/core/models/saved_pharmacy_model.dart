import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SavedPharmacyModel extends Equatable {
  const SavedPharmacyModel({
    required this.id,
    required this.pharmacyId,
    required this.savedAt,
  });

  final String id;
  final String pharmacyId;
  final DateTime savedAt;

  factory SavedPharmacyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final savedAt = data['savedAt'];
    return SavedPharmacyModel(
      id: doc.id,
      pharmacyId: data['pharmacyId'] as String? ?? '',
      savedAt: savedAt is Timestamp ? savedAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'pharmacyId': pharmacyId,
    'savedAt': Timestamp.fromDate(savedAt),
  };

  @override
  List<Object?> get props => [id, pharmacyId, savedAt];
}
