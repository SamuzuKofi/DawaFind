import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectLanguage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.chooseLanguageSubtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.greyText),
            ),
            const SizedBox(height: 16),
            _langRow(context, AppStrings.english, 'EN', selected: true),
            _langRow(context, AppStrings.french, 'FR', selected: false),
            _langRow(context, AppStrings.kirundi, 'KR', selected: false),
          ],
        ),
      ),
    );
  }

  Widget _langRow(
    BuildContext context,
    String label,
    String code, {
    required bool selected,
  }) => GestureDetector(
    onTap: () async {
      await PreferencesService.saveLanguage(code);
      if (!context.mounted) return;
      Navigator.pop(context);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lightGreyBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: selected ? AppColors.primaryGreen : AppColors.darkText,
            ),
          ),
          if (selected)
            const Icon(Icons.check, color: AppColors.primaryGreen, size: 18),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.topRight,
                child: OutlinedButton.icon(
                  onPressed: () => _showLanguagePicker(context),
                  icon: const Icon(Icons.language, size: 16),
                  label: const Text('EN'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkText,
                    side: const BorderSide(color: AppColors.lightGreyBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(
                    Icons.search,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.onboarding2Title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.onboarding2Subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.greyText),
              ),
              const SizedBox(height: 24),
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
                  onPressed: () async {
                    await PreferencesService.setOnboardingDone();
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  child: Text(
                    AppStrings.getStarted,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: Text(
                  AppStrings.alreadyHaveAccount,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
