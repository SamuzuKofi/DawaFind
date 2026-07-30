import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';

class Onboarding2Screen extends StatefulWidget {
  const Onboarding2Screen({super.key});

  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen> {
  // Two letter code of the language currently saved in SharedPreferences.
  // Loaded on first build so the chip shows the user's real choice after a
  // restart instead of always saying EN.
  String _language = 'EN';

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    final saved = await PreferencesService.getLanguage();
    if (!mounted) return;
    setState(() => _language = saved);
  }

  Future<void> _selectLanguage(String code) async {
    await PreferencesService.saveLanguage(code);
    if (!mounted) return;
    setState(() => _language = code);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Language set to ${PreferencesService.languageNames[code]}',
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.selectLanguage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                AppStrings.chooseLanguageSubtitle,
                style: TextStyle(fontSize: 13, color: AppColors.greyText),
              ),
              const SizedBox(height: 16),
              _langRow(AppStrings.english, 'EN'),
              _langRow(AppStrings.french, 'FR'),
              _langRow(AppStrings.kirundi, 'KR'),
            ],
          ),
        ),
      ),
    );
  }

  /// One row of the language sheet. The tick follows the saved language, so
  /// reopening the sheet after a restart shows the correct selection.
  Widget _langRow(String label, String code) {
    final bool selected = _language == code;
    return InkWell(
      onTap: () => _selectLanguage(code),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isPortrait =
                constraints.maxHeight >= constraints.maxWidth;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.topRight,
                        child: OutlinedButton.icon(
                          onPressed: _showLanguagePicker,
                          icon: const Icon(Icons.language, size: 16),
                          label: Text(_language),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkText,
                            side: const BorderSide(
                              color: AppColors.lightGreyBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _illustration(isPortrait: isPortrait),
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
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.greyText,
                        ),
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
                          child: const Text(
                            AppStrings.getStarted,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        child: const Text(
                          AppStrings.alreadyHaveAccount,
                          style: TextStyle(
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
          },
        ),
      ),
    );
  }

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
          height: isPortrait ? 300 : 170,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(Icons.search, size: 80, color: AppColors.primaryGreen),
          ),
        ),
      );
}
