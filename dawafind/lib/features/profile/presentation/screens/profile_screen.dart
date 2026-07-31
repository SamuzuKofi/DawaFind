import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoaded());
  }

  /// Asks before signing out. The bloc clears the Firebase session; the local
  /// preferences are cleared here so a restart cannot land back on a home
  /// screen. Language and theme are kept — they belong to the device.
  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?'),
        content: const Text(
          'You will need to log in again to see your saved pharmacies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;
    context.read<ProfileBloc>().add(ProfileLogoutRequested());
  }

  Future<void> _showLanguagePicker() async {
    final String current = await PreferencesService.getLanguage();
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PreferencesService.languageNames.entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              trailing: entry.key == current
                  ? const Icon(Icons.check, color: AppColors.primaryGreen)
                  : null,
              onTap: () async {
                await PreferencesService.saveLanguage(entry.key);
                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (!mounted) return;
                setState(() {}); // refresh the row's saved value
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language set to ${entry.value}'),
                    backgroundColor: AppColors.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileLoggedOut) {
          await PreferencesService.clearSession();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been logged out'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final name = state is ProfileReady ? state.name : '';
        final role = state is ProfileReady ? state.role : '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            iconTheme: const IconThemeData(color: AppColors.white),
          ),
          body: state is ProfileLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    _header(name, role),
                    const SizedBox(height: 8),
                    ..._menuItems.map(_menuTile),

                    // ----- Settings that persist across restarts -----
                    _sectionLabel('Settings'),
                    _darkModeTile(),
                    _languageTile(),

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
                        onPressed: _confirmLogout,
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

  Widget _header(String name, String role) => Container(
    color: AppColors.primaryGreen,
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
    child: Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.white,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
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
              role,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.greyText,
      ),
    ),
  );

  Widget _menuTile(Map<String, Object> item) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(item['icon'] as IconData, color: AppColors.primaryGreen),
      title: Text(item['label'] as String),
      trailing: const Icon(Icons.chevron_right, color: AppColors.greyText),
      onTap: () {
        if (item['label'] == 'Saved Pharmacies') {
          Navigator.pushNamed(context, AppRoutes.savedPharmacies);
        }
      },
    ),
  );

  /// Listens to the ThemeController so the switch always shows the real state,
  /// including the value restored from SharedPreferences at launch.
  Widget _darkModeTile() => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) => SwitchListTile(
        secondary: const Icon(
          Icons.dark_mode_outlined,
          color: AppColors.primaryGreen,
        ),
        title: const Text('Dark Mode'),
        value: mode == ThemeMode.dark,
        onChanged: (value) => ThemeController.instance.setDark(value),
      ),
    ),
  );

  /// Reads the stored language so the row shows the saved value on every
  /// launch, not a hardcoded default.
  Widget _languageTile() => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: FutureBuilder<String>(
      future: PreferencesService.getLanguage(),
      builder: (context, snapshot) {
        final String code = snapshot.data ?? 'EN';
        return ListTile(
          leading: const Icon(Icons.language, color: AppColors.primaryGreen),
          title: const Text('Language'),
          trailing: Text(
            PreferencesService.languageNames[code] ?? 'English',
            style: const TextStyle(color: AppColors.greyText),
          ),
          onTap: _showLanguagePicker,
        );
      },
    ),
  );
}
