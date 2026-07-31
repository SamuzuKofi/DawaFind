import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../pharmacy/data/repositories/pharmacy_repository_impl.dart';
import '../../../pharmacy/domain/entities/pharmacy_detail_entity.dart';
import '../../../pharmacy/domain/repositories/pharmacy_repository.dart';

part 'pharmacy_detail_event.dart';
part 'pharmacy_detail_state.dart';

class PharmacyDetailBloc
    extends Bloc<PharmacyDetailEvent, PharmacyDetailState> {
  PharmacyDetailBloc({PharmacyRepository? pharmacyRepository})
    : _pharmacyRepository = pharmacyRepository ?? PharmacyRepositoryImpl(),
      super(PharmacyDetailInitial()) {
    on<PharmacyDetailRequested>(_onRequested);
    on<PharmacyDetailSaveToggled>(_onSaveToggled);
    on<PharmacyDetailRatingSubmitted>(_onRatingSubmitted);
    on<PharmacyDetailRatingRemoved>(_onRatingRemoved);
  }

  final PharmacyRepository _pharmacyRepository;

  Future<void> _onRequested(
    PharmacyDetailRequested event,
    Emitter<PharmacyDetailState> emit,
  ) async {
    emit(PharmacyDetailLoading());
    // An empty id means the screen was opened without its route argument.
    // Firestore rejects an empty document path, so this is caught here to
    // report the real problem instead of a confusing backend error.
    if (event.pharmacyId.isEmpty) {
      emit(
        PharmacyDetailError(
          message: 'No pharmacy was selected. Please pick one from the list.',
        ),
      );
      return;
    }
    await _load(event.pharmacyId, emit);
  }

  Future<void> _onSaveToggled(
    PharmacyDetailSaveToggled event,
    Emitter<PharmacyDetailState> emit,
  ) async {
    final current = state;
    if (current is! PharmacyDetailReady) return;
    try {
      if (current.isSaved) {
        await _pharmacyRepository.removePharmacy(event.pharmacyId);
      } else {
        await _pharmacyRepository.savePharmacy(event.pharmacyId);
      }
      emit(
        PharmacyDetailReady(
          pharmacy: current.pharmacy,
          isSaved: !current.isSaved,
          myRating: current.myRating,
        ),
      );
    } on AppException catch (e) {
      emit(PharmacyDetailError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(PharmacyDetailError(message: 'Could not load this pharmacy.'));
    }
  }

  Future<void> _onRatingSubmitted(
    PharmacyDetailRatingSubmitted event,
    Emitter<PharmacyDetailState> emit,
  ) async {
    try {
      await _pharmacyRepository.submitRating(event.pharmacyId, event.score);
      await _load(event.pharmacyId, emit);
    } on AppException catch (e) {
      emit(PharmacyDetailError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(PharmacyDetailError(message: 'Could not load this pharmacy.'));
    }
  }

  Future<void> _onRatingRemoved(
    PharmacyDetailRatingRemoved event,
    Emitter<PharmacyDetailState> emit,
  ) async {
    try {
      await _pharmacyRepository.removeRating(event.pharmacyId);
      await _load(event.pharmacyId, emit);
    } on AppException catch (e) {
      emit(PharmacyDetailError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(PharmacyDetailError(message: 'Could not load this pharmacy.'));
    }
  }

  // Shared by the initial load and by both rating mutations, since a
  // rating changes the pharmacy's averageRating/ratingCount aggregate too
  // — the whole detail view needs refreshing, not just the score.
  Future<void> _load(String pharmacyId, Emitter<PharmacyDetailState> emit) async {
    try {
      final pharmacy = await _pharmacyRepository.getPharmacyById(pharmacyId);
      final isSaved = await _pharmacyRepository.isPharmacySaved(pharmacyId);
      final myRating = await _pharmacyRepository.getMyRating(pharmacyId);
      emit(
        PharmacyDetailReady(
          pharmacy: pharmacy,
          isSaved: isSaved,
          myRating: myRating,
        ),
      );
    } on AppException catch (e) {
      emit(PharmacyDetailError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(PharmacyDetailError(message: 'Could not load this pharmacy.'));
    }
  }
}
