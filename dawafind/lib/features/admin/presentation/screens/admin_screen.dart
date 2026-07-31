import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/pharmacy_approval_entity.dart';
import '../bloc/admin_bloc.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Which row has a write in flight, so its buttons can't be tapped twice
  // while Firestore is still working. Cleared whenever a new state lands.
  String? _busyPharmacyId;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminDashboardLoaded());
  }

  void _approve(PharmacyApprovalEntity pharmacy) {
    setState(() => _busyPharmacyId = pharmacy.pharmacyId);
    context.read<AdminBloc>().add(
      AdminPharmacyApproved(pharmacyId: pharmacy.pharmacyId),
    );
  }

  /// Rejection hides the listing from every patient, so it asks first.
  Future<void> _confirmReject(PharmacyApprovalEntity pharmacy) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject this pharmacy?'),
        content: Text(
          '${pharmacy.name} will stay hidden from patients until an admin '
          'approves it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Reject',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _busyPharmacyId = pharmacy.pharmacyId);
    context.read<AdminBloc>().add(
      AdminPharmacyRejected(pharmacyId: pharmacy.pharmacyId),
    );
  }

  /// Ends the Firebase session as well as the local one, so the next sign-in
  /// does not run as the previous admin.
  Future<void> _logout() async {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    await PreferencesService.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () =>
                context.read<AdminBloc>().add(AdminDashboardLoaded()),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          // Any resolved state means the in-flight write finished.
          setState(() => _busyPharmacyId = null);
          if (state is AdminError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading || state is AdminInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (state is AdminError) {
            return _errorState(context, state.message);
          }
          if (state is AdminDashboardReady) {
            if (state.pendingApprovals.isEmpty) return _emptyState();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _countBanner(state.pendingApprovals.length),
                const SizedBox(height: 12),
                ...state.pendingApprovals.map(_approvalCard),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _countBanner(int count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.lightGreen,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.pending_actions, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            count == 1
                ? '1 pharmacy is waiting for review'
                : '$count pharmacies are waiting for review',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _approvalCard(PharmacyApprovalEntity pharmacy) {
    final busy = _busyPharmacyId == pharmacy.pharmacyId;
    // While one row is writing, the others stay disabled too: the list is
    // about to be replaced by a reload, so a second tap would race it.
    final locked = _busyPharmacyId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    Icons.local_pharmacy,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pharmacy.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(pharmacy.status),
              ],
            ),
            if (pharmacy.phone.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 15,
                    color: AppColors.greyText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pharmacy.phone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            if (busy)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: locked
                          ? null
                          : () => _confirmReject(pharmacy),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Reject',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: locked ? null : () => _approve(pharmacy),
                      icon: const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.white,
                      ),
                      label: const Text(
                        'Approve',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4E5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      status,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFFB26A00),
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 64,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nothing to review',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Every pharmacy has been reviewed. New submissions will show up '
            'here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.greyText),
          ),
        ],
      ),
    ),
  );

  Widget _errorState(BuildContext context, String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () =>
                context.read<AdminBloc>().add(AdminDashboardLoaded()),
            child: const Text(
              'Try again',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    ),
  );
}
