import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/home_bloc.dart';

class HomePharmacistScreen extends StatelessWidget {
  const HomePharmacistScreen({super.key});

  static const _stats = [
    {'label': 'Total Drugs', 'value': '124', 'icon': Icons.medication},
    {'label': 'In Stock', 'value': '98', 'icon': Icons.check_circle_outline},
    {'label': 'Out of Stock', 'value': '26', 'icon': Icons.warning_amber},
  ];

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(HomeLoaded());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final name =
                  state is HomeReady ? state.userName : 'Pharmacist';
              return _header(name);
            },
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
                  context,
                  icon: Icons.add_box_outlined,
                  title: 'Add New Drug',
                  subtitle: 'Add a new medicine to your inventory',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.inventory),
                ),
                _actionCard(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Manage Inventory',
                  subtitle: 'Update stock levels and prices',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.inventory),
                ),
                _actionCard(
                  context,
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
      bottomNavigationBar: _bottomNav(context),
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

  Widget _statsRow() => Row(
        children: _stats
            .map(
              (s) => Expanded(
                child: Card(
                  margin: const EdgeInsets.only(right: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(
                          s['icon'] as IconData,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['value'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          s['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      );

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.greyText),
          onTap: onTap,
        ),
      );

  Widget _bottomNav(BuildContext context) => BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.inactiveGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.logout), label: 'Logout'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.inventory);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.profile);
          if (i == 3) Navigator.pushNamed(context, AppRoutes.login);
        },
      );
}
