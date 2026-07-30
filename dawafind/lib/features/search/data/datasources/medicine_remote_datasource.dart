import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/medicine_model.dart';
import '../../../../core/models/pharmacy_model.dart';
import '../../../../core/models/stock_model.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/medicine_entity.dart';

class MedicineRemoteDataSource {
  MedicineRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Firestore whereIn caps at 30 values per query.
  static const _maxWhereIn = 30;

  // Appended to a prefix to build a range query that matches every string
  // starting with that prefix —  sorts after any realistic character.
  static const _prefixRangeEnd = '';

  Future<List<MedicineSearchResultEntity>> search(
    String query, {
    double? userLatitude,
    double? userLongitude,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final medicineSnapshot = await _firestore
        .collection(FirestorePaths.medicines)
        .where('nameLower', isGreaterThanOrEqualTo: normalized)
        .where('nameLower', isLessThan: '$normalized$_prefixRangeEnd')
        .limit(20)
        .get();

    unawaited(_logSearchHistory(normalized));

    if (medicineSnapshot.docs.isEmpty) return const [];

    final medicines = {
      for (final doc in medicineSnapshot.docs)
        doc.id: MedicineModel.fromFirestore(doc),
    };

    final stockDocs = await _fetchByFieldWhereIn(
      collection: FirestorePaths.stock,
      field: 'medicineId',
      values: medicines.keys.toList(),
    );
    if (stockDocs.isEmpty) return const [];

    final pharmacyIds = stockDocs
        .map((doc) => doc.data()['pharmacyId'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final pharmacyDocs = await _fetchByDocumentIdWhereIn(
      collection: FirestorePaths.pharmacies,
      ids: pharmacyIds,
    );
    final pharmacies = {
      for (final doc in pharmacyDocs) doc.id: PharmacyModel.fromFirestore(doc),
    };

    final results = <MedicineSearchResultEntity>[];
    for (final stockDoc in stockDocs) {
      final stock = StockModel.fromFirestore(stockDoc);
      final medicine = medicines[stock.medicineId];
      final pharmacy = pharmacies[stock.pharmacyId];
      // Skip listings whose pharmacy hasn't been admin-approved, or whose
      // medicine/pharmacy doc vanished between the two queries above.
      if (medicine == null ||
          pharmacy == null ||
          pharmacy.status != PharmacyStatus.approved) {
        continue;
      }

      final distance = (userLatitude != null && userLongitude != null)
          ? GeoUtils.distanceKm(
              userLatitude,
              userLongitude,
              pharmacy.latitude,
              pharmacy.longitude,
            )
          : null;

      results.add(
        MedicineSearchResultEntity(
          stockId: stock.stockId,
          medicineId: medicine.medicineId,
          medicineName: medicine.name,
          dosage: medicine.dosage,
          form: medicine.form,
          packSize: stock.packSize,
          pharmacyId: pharmacy.pharmacyId,
          pharmacyName: pharmacy.name,
          price: stock.price,
          quantity: stock.quantity,
          distanceKm: distance,
        ),
      );
    }

    results.sort((a, b) {
      if (a.inStock != b.inStock) return a.inStock ? -1 : 1;
      if (a.distanceKm != null && b.distanceKm != null) {
        return a.distanceKm!.compareTo(b.distanceKm!);
      }
      return 0;
    });

    return results;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchByFieldWhereIn({
    required String collection,
    required String field,
    required List<String> values,
  }) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < values.length; i += _maxWhereIn) {
      final batch = values.sublist(i, min(i + _maxWhereIn, values.length));
      final snapshot = await _firestore
          .collection(collection)
          .where(field, whereIn: batch)
          .get();
      docs.addAll(snapshot.docs);
    }
    return docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchByDocumentIdWhereIn({
    required String collection,
    required List<String> ids,
  }) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < ids.length; i += _maxWhereIn) {
      final batch = ids.sublist(i, min(i + _maxWhereIn, ids.length));
      final snapshot = await _firestore
          .collection(collection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      docs.addAll(snapshot.docs);
    }
    return docs;
  }

  // Best-effort write to Search_History; a signed-out user simply has no
  // uid to log against, and a failure here must never break the search
  // itself, so errors are swallowed rather than surfaced.
  Future<void> _logSearchHistory(String queryText) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.searchHistory)
          .add({
            'queryText': queryText,
            'searchedAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {
      // Search history is a nice-to-have; it must never break search itself.
    }
  }
}
