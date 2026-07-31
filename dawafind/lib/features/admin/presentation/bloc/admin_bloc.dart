import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/pharmacy_approval_entity.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({AdminRepository? adminRepository})
    : _adminRepository = adminRepository ?? AdminRepositoryImpl(),
      super(AdminInitial()) {
    on<AdminDashboardLoaded>(_onDashboardLoaded);
    on<AdminPharmacyApproved>(_onPharmacyApproved);
    on<AdminPharmacyRejected>(_onPharmacyRejected);
  }

  final AdminRepository _adminRepository;

  Future<void> _onDashboardLoaded(
    AdminDashboardLoaded event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    await _reload(emit);
  }

  Future<void> _onPharmacyApproved(
    AdminPharmacyApproved event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.approvePharmacy(event.pharmacyId);
      await _reload(emit);
    } on AppException catch (e) {
      emit(AdminError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(AdminError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onPharmacyRejected(
    AdminPharmacyRejected event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.rejectPharmacy(event.pharmacyId);
      await _reload(emit);
    } on AppException catch (e) {
      emit(AdminError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(AdminError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _reload(Emitter<AdminState> emit) async {
    try {
      final pendingApprovals = await _adminRepository.getPendingApprovals();
      emit(AdminDashboardReady(pendingApprovals: pendingApprovals));
    } on AppException catch (e) {
      emit(AdminError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(AdminError(message: 'Something went wrong. Please try again.'));
    }
  }
}
