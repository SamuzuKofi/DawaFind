part of 'pharmacy_detail_bloc.dart';

abstract class PharmacyDetailState {}

class PharmacyDetailInitial extends PharmacyDetailState {}

class PharmacyDetailLoading extends PharmacyDetailState {}

class PharmacyDetailReady extends PharmacyDetailState {
  PharmacyDetailReady({required this.pharmacyId});
  final String pharmacyId;
}

class PharmacyDetailError extends PharmacyDetailState {
  PharmacyDetailError({required this.message});
  final String message;
}
