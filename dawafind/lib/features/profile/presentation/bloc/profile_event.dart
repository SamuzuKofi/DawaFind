part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileLoaded extends ProfileEvent {}

class ProfileLogoutRequested extends ProfileEvent {}
