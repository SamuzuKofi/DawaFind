part of 'admin_bloc.dart';

abstract class AdminEvent {}

class AdminDashboardLoaded extends AdminEvent {}

class AdminPharmacyApproved extends AdminEvent {
  AdminPharmacyApproved({required this.pharmacyId});
  final String pharmacyId;
}

class AdminPharmacyRejected extends AdminEvent {
  AdminPharmacyRejected({required this.pharmacyId});
  final String pharmacyId;
}
