part of 'admin_bloc.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  AdminDashboardLoaded({required this.pendingApprovals});
  final List<dynamic> pendingApprovals;
}

class AdminError extends AdminState {
  AdminError({required this.message});
  final String message;
}
