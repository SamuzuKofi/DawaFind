import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StockModel extends Equatable {
  const StockModel({
    required this.stockId,
    required this.pharmacyId,
    required this.medicineId,
    required this.price,
    required this.quantity,
    required this.packSize,
    required this.lastUpdated,
  });

  final String stockId;
  final String pharmacyId;
  final String medicineId;
  final double price;
  final int quantity;
  final String packSize;
  final DateTime lastUpdated;

  factory StockModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final lastUpdated = data['lastUpdated'];
    return StockModel(
      stockId: doc.id,
      pharmacyId: data['pharmacyId'] as String? ?? '',
      medicineId: data['medicineId'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      packSize: data['packSize'] as String? ?? '',
      lastUpdated: lastUpdated is Timestamp
          ? lastUpdated.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'stockId': stockId,
    'pharmacyId': pharmacyId,
    'medicineId': medicineId,
    'price': price,
    'quantity': quantity,
    'packSize': packSize,
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };

  @override
  List<Object?> get props => [
    stockId,
    pharmacyId,
    medicineId,
    price,
    quantity,
    packSize,
    lastUpdated,
  ];
}
