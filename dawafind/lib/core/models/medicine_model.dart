import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MedicineModel extends Equatable {
  const MedicineModel({
    required this.medicineId,
    required this.name,
    required this.nameLower,
    required this.dosage,
    required this.form,
    required this.brandName,
  });

  // nameLower is derived here so every write already satisfies the
  // firestore.rules check that nameLower == name.lower().
  factory MedicineModel.create({
    required String medicineId,
    required String name,
    required String dosage,
    required String form,
    String brandName = '',
  }) => MedicineModel(
    medicineId: medicineId,
    name: name,
    nameLower: name.trim().toLowerCase(),
    dosage: dosage,
    form: form,
    brandName: brandName,
  );

  final String medicineId;
  final String name;
  final String nameLower;
  final String dosage;
  final String form;
  final String brandName;

  factory MedicineModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final name = data['name'] as String? ?? '';
    return MedicineModel(
      medicineId: doc.id,
      name: name,
      nameLower: data['nameLower'] as String? ?? name.toLowerCase(),
      dosage: data['dosage'] as String? ?? '',
      form: data['form'] as String? ?? '',
      brandName: data['brandName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'medicineId': medicineId,
    'name': name,
    'nameLower': nameLower,
    'dosage': dosage,
    'form': form,
    'brandName': brandName,
  };

  @override
  List<Object?> get props => [
    medicineId,
    name,
    nameLower,
    dosage,
    form,
    brandName,
  ];
}
