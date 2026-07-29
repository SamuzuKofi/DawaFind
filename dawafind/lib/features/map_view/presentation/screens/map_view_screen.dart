import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Nearby Pharmacies',
          style: TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            color: AppColors.lightGreen,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 80, color: AppColors.primaryGreen),
                  SizedBox(height: 12),
                  Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Google Maps integration goes here',
                    style: TextStyle(color: AppColors.greyText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    Icons.local_pharmacy,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: Text(
                  'Dawa Pharmacy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('0.8 km away · Open now'),
                trailing: Icon(Icons.directions, color: AppColors.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
