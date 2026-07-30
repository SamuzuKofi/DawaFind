part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated({required this.role});
  final String role; // 'patient' | 'pharmacist' | 'admin'
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  AuthError({required this.message});
  final String message;
}
