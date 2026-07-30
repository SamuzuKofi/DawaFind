import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/pharmacy_staff_model.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // The UI collects a phone number, but the ERD's User only has an `email`
  // field and Firebase email/password auth needs an email — so the phone
  // is turned into a stable synthetic address rather than adding a field
  // the ERD doesn't have.
  static String emailFromPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '$digits@dawafind.app';
  }

  Future<UserEntity> signUp({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    try {
      final email = emailFromPhone(phone);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _firestore.collection(FirestorePaths.users).doc(uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserEntity(
        uid: uid,
        fullName: fullName,
        email: email,
        role: 'patient',
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(_authMessage(e));
    }
  }

  Future<UserEntity> signIn({
    required String phone,
    required String password,
  }) async {
    try {
      final email = emailFromPhone(phone);
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _loadProfile(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AppException(_authMessage(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _loadProfile(firebaseUser.uid);
  }

  Future<UserEntity> _loadProfile(String uid) async {
    final staffDoc = await _firestore
        .collection(FirestorePaths.pharmacyStaff)
        .doc(uid)
        .get();
    if (staffDoc.exists) {
      final staff = PharmacyStaffModel.fromFirestore(staffDoc);
      return UserEntity(
        uid: staff.uid,
        fullName: staff.fullName,
        email: staff.email,
        role: 'pharmacist',
        pharmacyId: staff.pharmacyId,
      );
    }

    final userDoc = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();
    if (userDoc.exists) {
      final user = UserModel.fromFirestore(userDoc);
      return UserEntity(
        uid: user.uid,
        fullName: user.fullName,
        email: user.email,
        role: 'patient',
      );
    }

    throw const AppException(
      'No profile found for this account. Please contact support.',
    );
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this phone number.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect phone number or password.';
      case 'invalid-email':
        return 'Enter a valid phone number.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
