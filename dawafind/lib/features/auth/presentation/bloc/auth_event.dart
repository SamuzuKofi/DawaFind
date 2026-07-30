part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested({required this.phone, required this.password});
  final String phone;
  final String password;
}

class AuthRegisterRequested extends AuthEvent {
  AuthRegisterRequested({
    required this.fullName,
    required this.phone,
    required this.password,
  });
  final String fullName;
  final String phone;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {}
