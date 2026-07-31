import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> signUp({
    required String fullName,
    required String phone,
    required String password,
  }) => guard(
    () => _remoteDataSource.signUp(
      fullName: fullName,
      phone: phone,
      password: password,
    ),
    'Could not create your account. Please try again.',
  );

  @override
  Future<UserEntity> signIn({
    required String phone,
    required String password,
  }) => guard(
    () => _remoteDataSource.signIn(phone: phone, password: password),
    'Could not sign you in. Please try again.',
  );

  @override
  Future<void> signOut() =>
      guard(() => _remoteDataSource.signOut(), 'Could not sign you out.');

  @override
  Future<UserEntity?> getCurrentUser() => guard(
    () => _remoteDataSource.getCurrentUser(),
    'Could not load your profile.',
  );
}
