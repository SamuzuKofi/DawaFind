import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../pharmacy/data/repositories/pharmacy_repository_impl.dart';
import '../../../pharmacy/domain/entities/pharmacy_summary_entity.dart';
import '../../../pharmacy/domain/repositories/pharmacy_repository.dart';

part 'saved_pharmacies_event.dart';
part 'saved_pharmacies_state.dart';

class SavedPharmaciesBloc
    extends Bloc<SavedPharmaciesEvent, SavedPharmaciesState> {
  SavedPharmaciesBloc({PharmacyRepository? pharmacyRepository})
    : _pharmacyRepository = pharmacyRepository ?? PharmacyRepositoryImpl(),
      super(SavedPharmaciesInitial()) {
    on<SavedPharmaciesLoaded>(_onLoaded);
    on<PharmacyUnsaved>(_onPharmacyUnsaved);
  }

  final PharmacyRepository _pharmacyRepository;

  Future<void> _onLoaded(
    SavedPharmaciesLoaded event,
    Emitter<SavedPharmaciesState> emit,
  ) async {
    emit(SavedPharmaciesLoading());
    await _reload(emit);
  }

  Future<void> _onPharmacyUnsaved(
    PharmacyUnsaved event,
    Emitter<SavedPharmaciesState> emit,
  ) async {
    try {
      await _pharmacyRepository.removePharmacy(event.pharmacyId);
      await _reload(emit);
    } on AppException catch (e) {
      emit(SavedPharmaciesError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(SavedPharmaciesError(message: 'Could not load saved pharmacies.'));
    }
  }

  Future<void> _reload(Emitter<SavedPharmaciesState> emit) async {
    try {
      final pharmacies = await _pharmacyRepository.getSavedPharmacies();
      emit(SavedPharmaciesReady(pharmacies: pharmacies));
    } on AppException catch (e) {
      emit(SavedPharmaciesError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(SavedPharmaciesError(message: 'Could not load saved pharmacies.'));
    }
  }
}
