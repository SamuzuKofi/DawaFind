import 'package:flutter_bloc/flutter_bloc.dart';

part 'saved_pharmacies_event.dart';
part 'saved_pharmacies_state.dart';

class SavedPharmaciesBloc extends Bloc<SavedPharmaciesEvent, SavedPharmaciesState> {
  SavedPharmaciesBloc() : super(SavedPharmaciesInitial()) {
    on<SavedPharmaciesLoaded>(_onLoaded);
    on<PharmacyUnsaved>(_onPharmacyUnsaved);
  }

  Future<void> _onLoaded(
    SavedPharmaciesLoaded event,
    Emitter<SavedPharmaciesState> emit,
  ) async {
    emit(SavedPharmaciesLoading());
    // call PharmacyRepository.getSavedPharmacies()
  }

  Future<void> _onPharmacyUnsaved(
    PharmacyUnsaved event,
    Emitter<SavedPharmaciesState> emit,
  ) async {
    // call PharmacyRepository.removePharmacy(event.pharmacyId)
  }
}
