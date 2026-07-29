import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class SavedPharmaciesScreen extends StatelessWidget {
  const SavedPharmaciesScreen({super.key});

  static const _saved = [
    {'name': 'Dawa Pharmacy', 'distance': '0.8 km', 'open': true},
    {'name': 'Health Plus Pharmacy', 'distance': '1.2 km', 'open': true},
    {'name': 'City Pharma Kigali', 'distance': '2.1 km', 'open': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Saved Pharmacies',
            style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _saved.length,
        itemBuilder: (context, i) {
          final p = _saved[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                backgroundColor: AppColors.lightGreen,
                child: Icon(Icons.local_pharmacy,
                    color: AppColors.primaryGreen),
              ),
              title: Text(p['name'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText)),
              subtitle: Text(p['distance'] as String,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.greyText)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (p['open'] as bool) ? 'Open' : 'Closed',
                      style: TextStyle(
                          fontSize: 11,
                          color: (p['open'] as bool)
                              ? AppColors.primaryGreen
                              : AppColors.error),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: AppColors.greyText),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                  context, AppRoutes.pharmacyDetail),
            ),
          );
        },
      ),
    );
  }
}