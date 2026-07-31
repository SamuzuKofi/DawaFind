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
    this.requestedRole = 'patient',
  });
  final String fullName;
  final String phone;
  final String password;

  /// What the user picked on the sign-up form. Recorded on their account so
  /// an admin can promote them later — it never grants the role by itself.
  final String requestedRole;
}

class AuthLogoutRequested extends AuthEvent {}
