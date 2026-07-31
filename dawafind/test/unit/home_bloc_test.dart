import 'package:dawafind/features/auth/domain/entities/user_entity.dart';
import 'package:dawafind/features/auth/domain/repositories/auth_repository.dart';
import 'package:dawafind/features/home/presentation/bloc/home_bloc.dart';
import 'package:dawafind/features/pharmacy/domain/entities/pharmacy_detail_entity.dart';
import 'package:dawafind/features/pharmacy/domain/entities/pharmacy_summary_entity.dart';
import 'package:dawafind/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => const UserEntity(
    uid: 'u1',
    fullName: 'Marie Uwimana',
    email: 'm@dawafind.app',
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
  }) async => throw UnimplementedError();
}

class _FakePharmacyRepository implements PharmacyRepository {
  @override
  Future<List<PharmacySummaryEntity>> getNearbyPharmacies({
    double? userLatitude,
    double? userLongitude,
    int limit = 10,
  }) async => const [
    PharmacySummaryEntity(
      pharmacyId: 'dawa-pharmacy',
      name: 'Dawa Pharmacy',
      address: 'Bwiza, Bujumbura',
      latitude: -3.3822,
      longitude: 29.3644,
      averageRating: 4.7,
    ),
  ];

  @override
  Future<PharmacyDetailEntity> getPharmacyById(String pharmacyId) async =>
      throw UnimplementedError();

  @override
  Future<bool> isPharmacySaved(String pharmacyId) async => false;

  @override
  Future<double?> getMyRating(String pharmacyId) async => null;

  @override
  Future<void> savePharmacy(String pharmacyId) async {}

  @override
  Future<void> removePharmacy(String pharmacyId) async {}

  @override
  Future<void> removeRating(String pharmacyId) async {}

  @override
  Future<void> submitRating(String pharmacyId, double score) async {}

  @override
  Future<List<PharmacySummaryEntity>> getSavedPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) async => const [];
}

void main() {
  // HomeBloc used to emit Loading and then nothing at all, so the home screen
  // never left its loading state and the pharmacy list stayed hardcoded.
  test('HomeBloc resolves to Ready with the user and real pharmacies',
      () async {
    final bloc = HomeBloc(
      authRepository: _FakeAuthRepository(),
      pharmacyRepository: _FakePharmacyRepository(),
    );
    final states = <HomeState>[];
    bloc.stream.listen(states.add);

    bloc.add(HomeLoaded());
    await Future.delayed(const Duration(milliseconds: 50));

    expect(states.first, isA<HomeLoading>());
    expect(states.last, isA<HomeReady>());

    final ready = states.last as HomeReady;
    expect(ready.userName, 'Marie Uwimana');
    expect(ready.pharmacies, hasLength(1));
    expect(
      ready.pharmacies.first.pharmacyId,
      'dawa-pharmacy',
      reason: 'cards need a real id so the detail screen can load',
    );
    await bloc.close();
  });
}
