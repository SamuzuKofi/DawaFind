import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitial()) {
    on<AdminDashboardLoaded>(_onDashboardLoaded);
    on<AdminPharmacyApproved>(_onPharmacyApproved);
    on<AdminPharmacyRejected>(_onPharmacyRejected);
  }

  Future<void> _onDashboardLoaded(
    AdminDashboardLoaded event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    // call AdminRepository.getPendingApprovals()
  }

  Future<void> _onPharmacyApproved(
    AdminPharmacyApproved event,
    Emitter<AdminState> emit,
  ) async {
    // call AdminRepository.approvePharmacy(event.pharmacyId)
  }

  Future<void> _onPharmacyRejected(
    AdminPharmacyRejected event,
    Emitter<AdminState> emit,
  ) async {
    // call AdminRepository.rejectPharmacy(event.pharmacyId)
  }
}
