part of 'pharmacy_detail_bloc.dart';

abstract class PharmacyDetailEvent {}

class PharmacyDetailRequested extends PharmacyDetailEvent {
  PharmacyDetailRequested({required this.pharmacyId});
  final String pharmacyId;
}

class PharmacyDetailSaveToggled extends PharmacyDetailEvent {
  PharmacyDetailSaveToggled({required this.pharmacyId});
  final String pharmacyId;
}

class PharmacyDetailRatingSubmitted extends PharmacyDetailEvent {
  PharmacyDetailRatingSubmitted({required this.pharmacyId, required this.score});
  final String pharmacyId;
  final double score;
}

class PharmacyDetailRatingRemoved extends PharmacyDetailEvent {
  PharmacyDetailRatingRemoved({required this.pharmacyId});
  final String pharmacyId;
}
