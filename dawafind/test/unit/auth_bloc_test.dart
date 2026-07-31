import 'package:dawafind/features/auth/domain/entities/user_entity.dart';
import 'package:dawafind/features/auth/domain/repositories/auth_repository.dart';
import 'package:dawafind/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAuthRepository implements AuthRepository {
  String? requestedRoleSeen;

  @override
  Future<UserEntity> signUp({
    required String fullName,
    required String phone,
    required String password,
    String requestedRole = 'patient',
  }) async {
    requestedRoleSeen = requestedRole;
    // Mirrors the real datasource: a new account is always a patient, no
    // matter which role was asked for.
    return const UserEntity(
      uid: 'u1',
      fullName: 'Aline N.',
      email: '25779000000@dawafind.app',
      role: 'patient',
    );
  }

  @override
  Future<UserEntity> signIn({
    required String phone,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<UserEntity?> getCurrentUser() async => null;
}

void main() {
  group('AuthBloc registration', () {
    // Regression test: the sign-up form collected an account type that the
    // event had no field for, so picking "Pharmacist" was silently dropped.
    test('carries the requested role through to the repository', () async {
      final repo = _RecordingAuthRepository();
      final bloc = AuthBloc(authRepository: repo);

      bloc.add(
        AuthRegisterRequested(
          fullName: 'Aline N.',
          phone: '+25779000000',
          password: 'secret123',
          requestedRole: 'pharmacist',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.requestedRoleSeen, 'pharmacist');
      await bloc.close();
    });

    test('grants patient even when pharmacist was requested', () async {
      final repo = _RecordingAuthRepository();
      final bloc = AuthBloc(authRepository: repo);

      bloc.add(
        AuthRegisterRequested(
          fullName: 'Aline N.',
          phone: '+25779000000',
          password: 'secret123',
          requestedRole: 'pharmacist',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));

      // Asking is not being granted — promotion is an admin action.
      expect((bloc.state as AuthAuthenticated).role, 'patient');
      await bloc.close();
    });

    test('defaults to patient when no role is picked', () async {
      final repo = _RecordingAuthRepository();
      final bloc = AuthBloc(authRepository: repo);

      bloc.add(
        AuthRegisterRequested(
          fullName: 'Aline N.',
          phone: '+25779000000',
          password: 'secret123',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.requestedRoleSeen, 'patient');
      await bloc.close();
    });
  });
}
