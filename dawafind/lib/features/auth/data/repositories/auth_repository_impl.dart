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
  }) => _remoteDataSource.signUp(
    fullName: fullName,
    phone: phone,
    password: password,
  );

  @override
  Future<UserEntity> signIn({required String phone, required String password}) =>
      _remoteDataSource.signIn(phone: phone, password: password);

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Future<UserEntity?> getCurrentUser() => _remoteDataSource.getCurrentUser();
}
