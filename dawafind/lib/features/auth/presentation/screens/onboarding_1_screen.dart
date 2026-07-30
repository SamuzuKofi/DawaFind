import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        // LayoutBuilder reports the height actually left after the status bar.
        // We need it for two reasons: to shrink the illustration in landscape,
        // and to give the column a minimum height so the Spacer below still
        // pushes the copy to the bottom in portrait.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isPortrait = constraints.maxHeight >= constraints.maxWidth;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                // IntrinsicHeight lets the Spacer keep working inside a scroll
                // view. In portrait the column is stretched to fill the screen
                // and looks identical to before; in landscape it grows past the
                // screen and scrolls instead of overflowing.
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _illustration(isPortrait: isPortrait),
                      const Spacer(),
                      Text(
                        AppStrings.onboarding1Title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.onboarding1Subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.greyText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(active: true),
                          const SizedBox(width: 8),
                          _dot(active: false),
                        ],
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
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.onboarding2),
                          child: const Text(
                            AppStrings.next,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Rounded illustration block. It is shorter in landscape so the rest of the
  /// content still fits, and it fades and scales in when the screen opens.
  Widget _illustration({required bool isPortrait}) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.95 + (0.05 * value), child: child),
        ),
        child: Container(
          width: double.infinity,
          height: isPortrait ? 320 : 180,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.directions_walk,
              size: 80,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      );

  Widget _dot({required bool active}) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? AppColors.primaryGreen : AppColors.lightGreyBorder,
    ),
  );
}
