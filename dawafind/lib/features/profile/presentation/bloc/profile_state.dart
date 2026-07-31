part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileReady extends ProfileState {
  ProfileReady({required this.name, required this.role});
  final String name;
  final String role;
}

class ProfileLoggedOut extends ProfileState {}

class ProfileError extends ProfileState {
  ProfileError({required this.message});
  final String message;
}
