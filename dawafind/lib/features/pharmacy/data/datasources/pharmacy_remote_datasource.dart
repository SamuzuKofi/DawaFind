import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/medicine_model.dart';
import '../../../../core/models/pharmacy_model.dart';
import '../../../../core/models/rating_model.dart';
import '../../../../core/models/saved_pharmacy_model.dart';
import '../../../../core/models/stock_model.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/pharmacy_detail_entity.dart';
import '../../domain/entities/pharmacy_summary_entity.dart';

class PharmacyRemoteDataSource {
  PharmacyRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _maxWhereIn = 30;

  Future<PharmacyDetailEntity> getPharmacyById(String pharmacyId) async {
    final doc = await _firestore
        .collection(FirestorePaths.pharmacies)
        .doc(pharmacyId)
        .get();
    if (!doc.exists) {
      throw const AppException('This pharmacy could not be found.');
    }
    final pharmacy = PharmacyModel.fromFirestore(doc);

    final stockSnapshot = await _firestore
        .collection(FirestorePaths.stock)
        .where('pharmacyId', isEqualTo: pharmacyId)
        .get();
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
      for (final medicineDoc in snapshot.docs) {
        medicines[medicineDoc.id] = MedicineModel.fromFirestore(medicineDoc);
      }
    }

    final stockItems = stocks
        .map((stock) {
          final medicine = medicines[stock.medicineId];
          if (medicine == null) return null;
          return PharmacyStockItemEntity(
            medicineId: medicine.medicineId,
            medicineName: medicine.name,
            dosage: medicine.dosage,
            form: medicine.form,
            packSize: stock.packSize,
            price: stock.price,
            quantity: stock.quantity,
          );
        })
        .whereType<PharmacyStockItemEntity>()
        .toList();
    stockItems.sort((a, b) {
      if (a.inStock != b.inStock) return a.inStock ? -1 : 1;
      return a.medicineName.compareTo(b.medicineName);
    });

    return PharmacyDetailEntity(
      pharmacyId: pharmacy.pharmacyId,
      name: pharmacy.name,
      address: pharmacy.address,
      phone: pharmacy.phone,
      latitude: pharmacy.latitude,
      longitude: pharmacy.longitude,
      openingHours: pharmacy.openingHours,
      averageRating: pharmacy.averageRating,
      ratingCount: pharmacy.ratingCount,
      stock: stockItems,
    );
  }

  Future<bool> isPharmacySaved(String pharmacyId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _savedPharmacyDoc(uid, pharmacyId).get();
    return doc.exists;
  }

  // The saved-pharmacy doc ID is the pharmacyId itself, so saving twice is
  // naturally idempotent and "is this saved?" is a plain existence check
  // instead of a query.
  Future<void> savePharmacy(String pharmacyId) async {
    final uid = _requireUid();
    await _savedPharmacyDoc(uid, pharmacyId).set({
      'id': pharmacyId,
      'pharmacyId': pharmacyId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removePharmacy(String pharmacyId) async {
    final uid = _requireUid();
    await _savedPharmacyDoc(uid, pharmacyId).delete();
  }

  Future<List<PharmacySummaryEntity>> getSavedPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) async {
    final uid = _requireUid();
    final savedSnapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.savedPharmacies)
        .get();
    if (savedSnapshot.docs.isEmpty) return const [];

    final pharmacyIds = savedSnapshot.docs
        .map((doc) => SavedPharmacyModel.fromFirestore(doc).pharmacyId)
        .toList();

    final pharmacyDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < pharmacyIds.length; i += _maxWhereIn) {
      final batch = pharmacyIds.sublist(
        i,
        min(i + _maxWhereIn, pharmacyIds.length),
      );
      final snapshot = await _firestore
          .collection(FirestorePaths.pharmacies)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      pharmacyDocs.addAll(snapshot.docs);
    }

    return pharmacyDocs
        .map(PharmacyModel.fromFirestore)
        .where((pharmacy) => pharmacy.status == PharmacyStatus.approved)
        .map(
          (pharmacy) => PharmacySummaryEntity(
            pharmacyId: pharmacy.pharmacyId,
            name: pharmacy.name,
            address: pharmacy.address,
            latitude: pharmacy.latitude,
            longitude: pharmacy.longitude,
            averageRating: pharmacy.averageRating,
            distanceKm: (userLatitude != null && userLongitude != null)
                ? GeoUtils.distanceKm(
                    userLatitude,
                    userLongitude,
                    pharmacy.latitude,
                    pharmacy.longitude,
                  )
                : null,
          ),
        )
        .toList();
  }

  Future<double?> getMyRating(String pharmacyId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _ratingDoc(pharmacyId, uid).get();
    if (!doc.exists) return null;
    return RatingModel.fromFirestore(doc).score;
  }

  Future<void> submitRating(String pharmacyId, double score) async {
    if (score < 1 || score > 5) {
      throw const AppException('Rating must be between 1 and 5.');
    }
    final uid = _requireUid();
    final pharmacyRef = _firestore
        .collection(FirestorePaths.pharmacies)
        .doc(pharmacyId);
    final ratingRef = _ratingDoc(pharmacyId, uid);

    await _firestore.runTransaction((transaction) async {
      final pharmacySnap = await transaction.get(pharmacyRef);
      if (!pharmacySnap.exists) {
        throw const AppException('This pharmacy could not be found.');
      }
      final ratingSnap = await transaction.get(ratingRef);

      final currentCount =
          (pharmacySnap.data()?['ratingCount'] as num?)?.toInt() ?? 0;
      final currentAverage =
          (pharmacySnap.data()?['averageRating'] as num?)?.toDouble() ?? 0;

      final int newCount;
      final double newAverage;
      if (ratingSnap.exists) {
        // Updating an existing rating: the count doesn't change, only the
        // weighted sum shifts by (newScore - previousScore).
        final previousScore =
            (ratingSnap.data()?['score'] as num?)?.toDouble() ?? 0;
        newCount = currentCount;
        newAverage = newCount > 0
            ? ((currentAverage * currentCount) - previousScore + score) /
                  newCount
            : score;
      } else {
        newCount = currentCount + 1;
        newAverage = ((currentAverage * currentCount) + score) / newCount;
      }

      transaction.set(ratingRef, {
        'userId': uid,
        'score': score,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(pharmacyRef, {
        'averageRating': newAverage,
        'ratingCount': newCount,
      });
    });
  }

  Future<void> removeRating(String pharmacyId) async {
    final uid = _requireUid();
    final pharmacyRef = _firestore
        .collection(FirestorePaths.pharmacies)
        .doc(pharmacyId);
    final ratingRef = _ratingDoc(pharmacyId, uid);

    await _firestore.runTransaction((transaction) async {
      final pharmacySnap = await transaction.get(pharmacyRef);
      final ratingSnap = await transaction.get(ratingRef);
      if (!ratingSnap.exists) return;

      final currentCount =
          (pharmacySnap.data()?['ratingCount'] as num?)?.toInt() ?? 0;
      final currentAverage =
          (pharmacySnap.data()?['averageRating'] as num?)?.toDouble() ?? 0;
      final previousScore =
          (ratingSnap.data()?['score'] as num?)?.toDouble() ?? 0;

      final newCount = currentCount > 0 ? currentCount - 1 : 0;
      final newAverage = newCount > 0
          ? ((currentAverage * currentCount) - previousScore) / newCount
          : 0.0;

      transaction.delete(ratingRef);
      transaction.update(pharmacyRef, {
        'averageRating': newAverage,
        'ratingCount': newCount,
      });
    });
  }

  DocumentReference<Map<String, dynamic>> _ratingDoc(
    String pharmacyId,
    String uid,
  ) => _firestore
      .collection(FirestorePaths.pharmacies)
      .doc(pharmacyId)
      .collection(FirestorePaths.ratings)
      .doc(uid);

  DocumentReference<Map<String, dynamic>> _savedPharmacyDoc(
    String uid,
    String pharmacyId,
  ) => _firestore
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.savedPharmacies)
      .doc(pharmacyId);

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AppException('Please sign in to save pharmacies.');
    }
    return uid;
  }
}
