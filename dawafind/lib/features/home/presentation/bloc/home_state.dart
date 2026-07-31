part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReady extends HomeState {
  HomeReady({
    required this.userName,
    required this.role,
    this.pharmacies = const [],
  });
  final String userName;
  final String role; // 'patient' | 'pharmacist'
  /// Approved pharmacies shown in the home screen's discovery list.
  final List<PharmacySummaryEntity> pharmacies;
}

class HomeError extends HomeState {
  HomeError({required this.message});
  final String message;
}
