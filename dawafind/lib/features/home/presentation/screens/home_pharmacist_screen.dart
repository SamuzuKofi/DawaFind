import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../bloc/home_bloc.dart';

class HomePharmacistScreen extends StatefulWidget {
  const HomePharmacistScreen({super.key});

  @override
  State<HomePharmacistScreen> createState() => _HomePharmacistScreenState();
}

class _HomePharmacistScreenState extends State<HomePharmacistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoaded());
    // Drives the stock counts in the overview cards.
    context.read<InventoryBloc>().add(InventoryLoaded());
  }

  /// The inventory screen builds its own InventoryBloc, so edits made there
  /// are invisible to this one. Reloading on return keeps the counts honest
  /// after a drug is added or removed.
  Future<void> _openInventory() async {
    await Navigator.pushNamed(context, AppRoutes.inventory);
    if (!mounted) return;
    context.read<InventoryBloc>().add(InventoryLoaded());
  }

  /// Ends the Firebase session as well as the local one. Clearing only the
  /// saved preferences would leave the previous account signed in underneath,
  /// so the next user's Firestore writes would run as them.
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
      body: Column(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) =>
                _header(state is HomeReady ? state.userName : 'Pharmacist'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionLabel('Inventory Overview'),
                const SizedBox(height: 8),
                _statsRow(),
                const SizedBox(height: 20),
                _sectionLabel('Quick Actions'),
                const SizedBox(height: 8),
                _actionCard(
                  icon: Icons.add_box_outlined,
                  title: 'Add New Drug',
                  subtitle: 'Add a new medicine to your inventory',
                  onTap: _openInventory,
                ),
                _actionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Manage Inventory',
                  subtitle: 'Update stock levels and prices',
                  onTap: _openInventory,
                ),
                _actionCard(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  subtitle: 'Manage your pharmacy profile',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header(String name) => Container(
    padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
    decoration: const BoxDecoration(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $name',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your pharmacy inventory',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );

  /// Counts come straight from the pharmacy's own stock documents, so the
  /// dashboard and the inventory screen can never disagree.
  Widget _statsRow() => BlocBuilder<InventoryBloc, InventoryState>(
    builder: (context, state) {
      if (state is InventoryError) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final items = state is InventorySuccess ? state.items : null;
      return Row(
        children: [
          _statCard(
            icon: Icons.medication,
            label: 'Total Drugs',
            value: items?.length,
          ),
          _statCard(
            icon: Icons.check_circle_outline,
            label: 'In Stock',
            value: items?.where((i) => !i.isOutOfStock).length,
          ),
          _statCard(
            icon: Icons.warning_amber,
            label: 'Out of Stock',
            value: items?.where((i) => i.isOutOfStock).length,
          ),
        ],
      );
    },
  );

  // A null value means the counts are still loading.
  Widget _statCard({
    required IconData icon,
    required String label,
    required int? value,
  }) => Expanded(
    child: Card(
      margin: const EdgeInsets.only(right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(height: 4),
            SizedBox(
              height: 26,
              child: value == null
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
  );

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 1,
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.lightGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryGreen),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: AppColors.greyText),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.greyText),
      onTap: onTap,
    ),
  );

  Widget _bottomNav() => BottomNavigationBar(
    currentIndex: 0,
    selectedItemColor: AppColors.primaryGreen,
    unselectedItemColor: AppColors.inactiveGrey,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        label: 'Inventory',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
    ],
    onTap: (i) {
      if (i == 1) _openInventory();
      if (i == 2) Navigator.pushNamed(context, AppRoutes.profile);
      if (i == 3) _logout();
    },
  );
}
