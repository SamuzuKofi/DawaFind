part of 'saved_pharmacies_bloc.dart';

abstract class SavedPharmaciesEvent {}

class SavedPharmaciesLoaded extends SavedPharmaciesEvent {}

class PharmacyUnsaved extends SavedPharmaciesEvent {
  PharmacyUnsaved({required this.pharmacyId});
  final String pharmacyId;
}
