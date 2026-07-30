part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReady extends HomeState {
  HomeReady({required this.userName, required this.role});
  final String userName;
  final String role; // 'patient' | 'pharmacist'
}

class HomeError extends HomeState {
  HomeError({required this.message});
  final String message;
}
