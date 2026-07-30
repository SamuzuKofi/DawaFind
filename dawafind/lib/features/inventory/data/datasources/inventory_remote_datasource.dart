import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/medicine_model.dart';
import '../../../../core/models/stock_model.dart';
import '../../domain/entities/inventory_item_entity.dart';

class InventoryRemoteDataSource {
  InventoryRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _maxWhereIn = 30;

  Future<List<InventoryItemEntity>> getItems() async {
    final pharmacyId = await _currentPharmacyId();

    final stockSnapshot = await _firestore
        .collection(FirestorePaths.stock)
        .where('pharmacyId', isEqualTo: pharmacyId)
        .get();
    if (stockSnapshot.docs.isEmpty) return const [];

    final stocks = stockSnapshot.docs.map(StockModel.fromFirestore).toList();
    final medicineIds = stocks.map((s) => s.medicineId).toSet().toList();

    final medicines = <String, MedicineModel>{};
    for (var i = 0; i < medicineIds.length; i += _maxWhereIn) {
      final batch = medicineIds.sublist(
        i,
        min(i + _maxWhereIn, medicineIds.length),
      );
      final snapshot = await _firestore
          .collection(FirestorePaths.medicines)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      for (final doc in snapshot.docs) {
        medicines[doc.id] = MedicineModel.fromFirestore(doc);
      }
    }

    final items = stocks
        .map((stock) {
          final medicine = medicines[stock.medicineId];
          if (medicine == null) return null;
          return InventoryItemEntity(
            stockId: stock.stockId,
            medicineId: medicine.medicineId,
            medicineName: medicine.name,
            dosage: medicine.dosage,
            form: medicine.form,
            packSize: stock.packSize,
            price: stock.price,
            quantity: stock.quantity,
            lastUpdated: stock.lastUpdated,
          );
        })
        .whereType<InventoryItemEntity>()
        .toList();

    items.sort((a, b) => a.medicineName.compareTo(b.medicineName));
    return items;
  }

  Future<void> addItem(InventoryItemDraft item) async {
    final pharmacyId = await _currentPharmacyId();
    final medicineId = await _findOrCreateMedicine(
      name: item.medicineName,
      dosage: item.dosage,
      form: item.form,
      brandName: item.brandName,
    );
    await _firestore.collection(FirestorePaths.stock).add({
      'pharmacyId': pharmacyId,
      'medicineId': medicineId,
      'price': item.price,
      'quantity': item.quantity,
      'packSize': item.packSize,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String stockId,
    required int quantity,
    required double price,
    required String packSize,
  }) async {
    await _firestore.collection(FirestorePaths.stock).doc(stockId).update({
      'quantity': quantity,
      'price': price,
      'packSize': packSize,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem(String stockId) async {
    await _firestore.collection(FirestorePaths.stock).doc(stockId).delete();
  }

  Future<String> _currentPharmacyId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AppException('You must be signed in as a pharmacist.');
    }
    final staffDoc = await _firestore
        .collection(FirestorePaths.pharmacyStaff)
        .doc(uid)
        .get();
    final pharmacyId = staffDoc.data()?['pharmacyId'] as String?;
    if (pharmacyId == null) {
      throw const AppException('No pharmacy is linked to this account.');
    }
    return pharmacyId;
  }

  // Reuses an existing catalogue entry for the same name+dosage+form
  // rather than creating a duplicate Medicine doc every time a pharmacist
  // adds stock of something another pharmacy already listed.
  Future<String> _findOrCreateMedicine({
    required String name,
    required String dosage,
    required String form,
    required String brandName,
  }) async {
    final nameLower = name.trim().toLowerCase();
    final existing = await _firestore
        .collection(FirestorePaths.medicines)
        .where('nameLower', isEqualTo: nameLower)
        .where('dosage', isEqualTo: dosage)
        .where('form', isEqualTo: form)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;

    final doc = await _firestore.collection(FirestorePaths.medicines).add({
      'name': name,
      'nameLower': nameLower,
      'dosage': dosage,
      'form': form,
      'brandName': brandName,
    });
    return doc.id;
  }
}
