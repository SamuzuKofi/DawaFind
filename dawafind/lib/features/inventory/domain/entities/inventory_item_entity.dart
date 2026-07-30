import 'package:equatable/equatable.dart';

/// One pharmacist-facing inventory row: their pharmacy's Stock entry
/// joined with the Medicine catalogue fields needed for display.
///
/// "Low stock" / "Out of stock" badges are derived from quantity rather
/// than a stored field — the ERD's Stock has no separate status column,
/// so this avoids adding one that isn't there.
class InventoryItemEntity extends Equatable {
  const InventoryItemEntity({
    required this.stockId,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.form,
    required this.packSize,
    required this.price,
    required this.quantity,
    required this.lastUpdated,
  });

  static const lowStockThreshold = 5;

  final String stockId;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String form;
  final String packSize;
  final double price;
  final int quantity;
  final DateTime lastUpdated;

  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;

  @override
  List<Object?> get props => [
    stockId,
    medicineId,
    medicineName,
    dosage,
    form,
    packSize,
    price,
    quantity,
    lastUpdated,
  ];
}

/// Input for creating a new inventory item. Kept separate from
/// InventoryItemEntity because a new item has no stockId, medicineId, or
/// lastUpdated until Firestore assigns/stamps them.
class InventoryItemDraft extends Equatable {
  const InventoryItemDraft({
    required this.medicineName,
    required this.dosage,
    required this.form,
    this.brandName = '',
    required this.packSize,
    required this.price,
    required this.quantity,
  });

  final String medicineName;
  final String dosage;
  final String form;
  final String brandName;
  final String packSize;
  final double price;
  final int quantity;

  @override
  List<Object?> get props => [
    medicineName,
    dosage,
    form,
    brandName,
    packSize,
    price,
    quantity,
  ];
}
