import 'package:dawafind/core/errors/app_exception.dart';
import 'package:dawafind/features/auth/domain/entities/user_entity.dart';
import 'package:dawafind/features/auth/domain/repositories/auth_repository.dart';
import 'package:dawafind/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Throws the kind of error a Firestore read raises when rules deny access or
/// the network drops — deliberately NOT an AppException.
class _ExplodingAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async =>
      throw StateError('firestore blew up');

  @override
  Future<void> signOut() async => throw StateError('network down');

  @override
  Future<UserEntity> signIn({
    required String phone,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<UserEntity> signUp({
    required String fullName,
    required String phone,
    required String password,
    String requestedRole = 'patient',
  }) async => throw UnimplementedError();
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => const UserEntity(
    uid: 'u1',
    fullName: 'Marie Uwimana',
    email: '25762345678@dawafind.app',
    role: 'patient',
  );

  @override
  Future<void> signOut() async {}

  @override
  Future<UserEntity> signIn({
    required String phone,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<UserEntity> signUp({
    required String fullName,
    required String phone,
    required String password,
    String requestedRole = 'patient',
  }) async => throw UnimplementedError();
}

void main() {
  group('ProfileBloc', () {
    test('emits Ready with the signed-in user', () async {
      final bloc = ProfileBloc(authRepository: _FakeAuthRepository());
      final states = <ProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(ProfileLoaded());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.first, isA<ProfileLoading>());
      expect(states.last, isA<ProfileReady>());
      expect((states.last as ProfileReady).name, 'Marie Uwimana');
      await bloc.close();
    });

    // Regression test for the bug where a non-AppException escaped the
    // handler, so the bloc never emitted after Loading and the profile
    // screen span forever.
    test('emits Error, not an endless Loading, when the backend throws',
        () async {
      final bloc = ProfileBloc(authRepository: _ExplodingAuthRepository());
      final states = <ProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(ProfileLoaded());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.first, isA<ProfileLoading>());
      expect(
        states.last,
        isA<ProfileError>(),
        reason: 'a backend failure must resolve to an error state',
      );
      await bloc.close();
    });

    test('logout completes even when the remote sign-out fails', () async {
      final bloc = ProfileBloc(authRepository: _ExplodingAuthRepository());
      final states = <ProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(ProfileLogoutRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.last, isA<ProfileLoggedOut>());
      await bloc.close();
    });
  });

  test('guard converts an arbitrary error into an AppException', () async {
    expect(
      () => guard(() async => throw StateError('boom'), 'friendly message'),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'friendly message',
        ),
      ),
    );
  });
}
