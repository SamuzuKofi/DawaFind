import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  /// Decides where a returning user lands. This is what makes the saved user
  /// type a genuinely restored preference: a pharmacist who closes the app
  /// reopens straight on the pharmacist dashboard.
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final bool onboarded = await PreferencesService.isOnboardingDone();
    if (!mounted) return;
    if (!onboarded) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding1);
      return;
    }

    final bool loggedIn = await PreferencesService.isLoggedIn();
    if (!mounted) return;
    if (!loggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final String userType = await PreferencesService.getUserType();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      userType == 'pharmacist'
          ? AppRoutes.homePharmacist
          : AppRoutes.homePatient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Shares a tag with the logo on the login screen so the mark flies
            // across instead of popping.
            Hero(
              tag: 'app-logo',
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primaryGreen,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.tagline,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(flex: 4),
            const Text(
              AppStrings.locationTag,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
