import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('My Profile',
            style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            color: AppColors.primaryGreen,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.white,
                  child: Text('F',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen)),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fadhili',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('Patient',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._menuItems.map((item) => Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(item['icon'] as IconData,
                      color: AppColors.primaryGreen),
                  title: Text(item['label'] as String,
                      style:
                          const TextStyle(color: AppColors.darkText)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.greyText),
                  onTap: () {
                    if (item['label'] == 'Saved Pharmacies') {
                      Navigator.pushNamed(
                          context, AppRoutes.savedPharmacies);
                    }
                  },
                ),
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false),
              child: const Text('Log Out',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}