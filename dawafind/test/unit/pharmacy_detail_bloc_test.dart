import 'package:dawafind/features/pharmacy/domain/entities/pharmacy_detail_entity.dart';
import 'package:dawafind/features/pharmacy/domain/entities/pharmacy_summary_entity.dart';
import 'package:dawafind/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:dawafind/features/pharmacy_detail/presentation/bloc/pharmacy_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingPharmacyRepository implements PharmacyRepository {
  final List<String> lookups = [];
  final List<String> saved = [];
  final List<String> unsaved = [];
  final List<double> submittedRatings = [];
  final List<String> clearedRatings = [];

  @override
  Future<PharmacyDetailEntity> getPharmacyById(String pharmacyId) async {
    lookups.add(pharmacyId);
    return const PharmacyDetailEntity(
      pharmacyId: 'p1',
      name: 'Dawa Pharmacy',
      address: 'Bwiza, Bujumbura',
      phone: '+25722234501',
      latitude: -3.3822,
      longitude: 29.3644,
      openingHours: {},
      averageRating: 4.7,
      ratingCount: 32,
      stock: [],
    );
  }

  @override
  Future<bool> isPharmacySaved(String pharmacyId) async => false;

  @override
  Future<double?> getMyRating(String pharmacyId) async => null;

  @override
  Future<void> savePharmacy(String pharmacyId) async => saved.add(pharmacyId);

  @override
  Future<void> removePharmacy(String pharmacyId) async =>
      unsaved.add(pharmacyId);

  @override
  Future<void> removeRating(String pharmacyId) async =>
      clearedRatings.add(pharmacyId);

  @override
  Future<void> submitRating(String pharmacyId, double score) async =>
      submittedRatings.add(score);

  @override
  Future<List<PharmacySummaryEntity>> getSavedPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) async => const [];

  @override
  Future<List<PharmacySummaryEntity>> getNearbyPharmacies({
    double? userLatitude,
    double? userLongitude,
    int limit = 10,
  }) async => const [];
}

void main() {
  group('PharmacyDetailBloc', () {
    test('loads a pharmacy when given an id', () async {
      final repo = _RecordingPharmacyRepository();
      final bloc = PharmacyDetailBloc(pharmacyRepository: repo);
      final states = <PharmacyDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(PharmacyDetailRequested(pharmacyId: 'p1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.last, isA<PharmacyDetailReady>());
      expect(repo.lookups, ['p1']);
      await bloc.close();
    });

    // Regression test: opening the screen without its route argument used to
    // send an empty document path to Firestore, which never resolved and left
    // the screen spinning.
    test('reports a clear error for an empty id instead of querying', () async {
      final repo = _RecordingPharmacyRepository();
      final bloc = PharmacyDetailBloc(pharmacyRepository: repo);
      final states = <PharmacyDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(PharmacyDetailRequested(pharmacyId: ''));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.last, isA<PharmacyDetailError>());
      expect((states.last as PharmacyDetailError).message, contains('No pharmacy'));
      expect(
        repo.lookups,
        isEmpty,
        reason: 'an empty id must never reach Firestore',
      );
      await bloc.close();
    });

    test('save toggle writes through and flips the saved flag', () async {
      final repo = _RecordingPharmacyRepository();
      final bloc = PharmacyDetailBloc(pharmacyRepository: repo);

      bloc.add(PharmacyDetailRequested(pharmacyId: 'p1'));
      await Future.delayed(const Duration(milliseconds: 50));
      expect((bloc.state as PharmacyDetailReady).isSaved, isFalse);

      bloc.add(PharmacyDetailSaveToggled(pharmacyId: 'p1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.saved, ['p1']);
      expect((bloc.state as PharmacyDetailReady).isSaved, isTrue);

      // Toggling again takes the other branch, so one control covers both.
      bloc.add(PharmacyDetailSaveToggled(pharmacyId: 'p1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.unsaved, ['p1']);
      expect((bloc.state as PharmacyDetailReady).isSaved, isFalse);
      await bloc.close();
    });

    test('submitting a rating reloads so the average reflects it', () async {
      final repo = _RecordingPharmacyRepository();
      final bloc = PharmacyDetailBloc(pharmacyRepository: repo);

      bloc.add(PharmacyDetailRequested(pharmacyId: 'p1'));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(PharmacyDetailRatingSubmitted(pharmacyId: 'p1', score: 4));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.submittedRatings, [4]);
      expect(
        repo.lookups,
        ['p1', 'p1'],
        reason: 'a new rating changes the aggregate, so the detail is refetched',
      );

      bloc.add(PharmacyDetailRatingRemoved(pharmacyId: 'p1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.clearedRatings, ['p1']);
      expect(bloc.state, isA<PharmacyDetailReady>());
      await bloc.close();
    });
  });
}
