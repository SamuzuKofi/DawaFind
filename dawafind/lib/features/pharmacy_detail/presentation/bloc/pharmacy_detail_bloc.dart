import 'package:flutter_bloc/flutter_bloc.dart';

part 'pharmacy_detail_event.dart';
part 'pharmacy_detail_state.dart';

class PharmacyDetailBloc extends Bloc<PharmacyDetailEvent, PharmacyDetailState> {
  PharmacyDetailBloc() : super(PharmacyDetailInitial()) {
    on<PharmacyDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PharmacyDetailRequested event,
    Emitter<PharmacyDetailState> emit,
  ) async {
    emit(PharmacyDetailLoading());
    // call PharmacyRepository.getPharmacyById(event.pharmacyId)
  }
}
