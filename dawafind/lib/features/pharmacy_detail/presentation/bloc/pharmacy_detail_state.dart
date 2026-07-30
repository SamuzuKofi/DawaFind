part of 'pharmacy_detail_bloc.dart';

abstract class PharmacyDetailState {}

class PharmacyDetailInitial extends PharmacyDetailState {}

class PharmacyDetailLoading extends PharmacyDetailState {}

class PharmacyDetailReady extends PharmacyDetailState {
  PharmacyDetailReady({
    required this.pharmacy,
    required this.isSaved,
    this.myRating,
  });
  final PharmacyDetailEntity pharmacy;
  final bool isSaved;
  final double? myRating;
}

class PharmacyDetailError extends PharmacyDetailState {
  PharmacyDetailError({required this.message});
  final String message;
}
