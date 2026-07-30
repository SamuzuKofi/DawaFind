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
  }

  final PharmacyRepository _pharmacyRepository;

  Future<void> _onRequested(
    PharmacyDetailRequested event,
    Emitter<PharmacyDetailState> emit,
  ) async {
    emit(PharmacyDetailLoading());
    try {
      final pharmacy = await _pharmacyRepository.getPharmacyById(
        event.pharmacyId,
      );
      final isSaved = await _pharmacyRepository.isPharmacySaved(
        event.pharmacyId,
      );
      emit(PharmacyDetailReady(pharmacy: pharmacy, isSaved: isSaved));
    } on AppException catch (e) {
      emit(PharmacyDetailError(message: e.message));
    }
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
        PharmacyDetailReady(pharmacy: current.pharmacy, isSaved: !current.isSaved),
      );
    } on AppException catch (e) {
      emit(PharmacyDetailError(message: e.message));
    }
  }
}
