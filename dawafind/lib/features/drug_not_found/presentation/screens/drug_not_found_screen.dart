import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';

class DrugNotFoundScreen extends StatelessWidget {
  const DrugNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 80,
              color: AppColors.inactiveGrey,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.medicineNotFound,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No pharmacy near you currently has this medicine. Try searching for an alternative or check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.greyText),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                child: Text(
                  AppStrings.searchAlternatives,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homePatient,
                  (_) => false,
                ),
                child: const Text(
                  'Go Home',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
