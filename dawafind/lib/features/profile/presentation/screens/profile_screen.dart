import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menuItems = [
    {'icon': Icons.person_outline, 'label': 'Edit Profile'},
    {'icon': Icons.location_on_outlined, 'label': 'My Location'},
    {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
    {'icon': Icons.bookmark_outline, 'label': 'Saved Pharmacies'},
    {'icon': Icons.history, 'label': 'Search History'},
    {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy & Security'},
    {'icon': Icons.help_outline, 'label': 'Help & Support'},
    {'icon': Icons.star_outline, 'label': 'Rate the App'},
  ];

  @override
  Widget build(BuildContext context) {
    context.read<ProfileBloc>().add(ProfileLoaded());

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.login, (_) => false);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final name = state is ProfileReady ? state.name : '';
        final role = state is ProfileReady ? state.role : '';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreen,
            title: const Text(
              'My Profile',
              style: TextStyle(color: AppColors.white),
            ),
            iconTheme: const IconThemeData(color: AppColors.white),
            elevation: 0,
          ),
          body: state is ProfileLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen))
              : ListView(
                  children: [
                    Container(
                      color: AppColors.primaryGreen,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.white,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isEmpty ? 'Loading...' : name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                role.isEmpty ? '' : role,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._menuItems.map(
                      (item) => Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            item['icon'] as IconData,
                            color: AppColors.primaryGreen,
                          ),
                          title: Text(
                            item['label'] as String,
                            style:
                                const TextStyle(color: AppColors.darkText),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.greyText,
                          ),
                          onTap: () {
                            if (item['label'] == 'Saved Pharmacies') {
                              Navigator.pushNamed(
                                  context, AppRoutes.savedPharmacies);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => context
                            .read<ProfileBloc>()
                            .add(ProfileLogoutRequested()),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        );
      },
    );
  }
}
