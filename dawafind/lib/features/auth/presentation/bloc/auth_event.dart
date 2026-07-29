part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested({required this.phone, required this.password});
  final String phone;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {}
