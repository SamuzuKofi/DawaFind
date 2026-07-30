part of 'pharmacy_detail_bloc.dart';

abstract class PharmacyDetailEvent {}

class PharmacyDetailRequested extends PharmacyDetailEvent {
  PharmacyDetailRequested({required this.pharmacyId});
  final String pharmacyId;
}
