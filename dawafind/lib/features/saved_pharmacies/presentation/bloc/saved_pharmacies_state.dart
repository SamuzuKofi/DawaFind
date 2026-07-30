part of 'saved_pharmacies_bloc.dart';

abstract class SavedPharmaciesState {}

class SavedPharmaciesInitial extends SavedPharmaciesState {}

class SavedPharmaciesLoading extends SavedPharmaciesState {}

class SavedPharmaciesReady extends SavedPharmaciesState {
  SavedPharmaciesReady({required this.pharmacies});
  final List<PharmacySummaryEntity> pharmacies;
}

class SavedPharmaciesError extends SavedPharmaciesState {
  SavedPharmaciesError({required this.message});
  final String message;
}
