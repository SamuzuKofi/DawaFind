import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/pharmacy_detail/presentation/bloc/pharmacy_detail_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/saved_pharmacies/presentation/bloc/saved_pharmacies_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_1_screen.dart';
import 'features/auth/presentation/screens/onboarding_2_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/home/presentation/screens/home_patient_screen.dart';
import 'features/home/presentation/screens/home_pharmacist_screen.dart';
import 'features/search/presentation/screens/medicine_search_screen.dart';
import 'features/inventory/presentation/screens/inventory_screen.dart';
import 'features/admin/presentation/screens/admin_screen.dart';
import 'features/drug_not_found/presentation/screens/drug_not_found_screen.dart';
import 'features/map_view/presentation/screens/map_view_screen.dart';
import 'features/pharmacy_detail/presentation/screens/pharmacy_detail_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/saved_pharmacies/presentation/screens/saved_pharmacies_screen.dart';

class DawaFindApp extends StatelessWidget {
  const DawaFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthBloc())],
      // Only MaterialApp rebuilds on a theme change, so the blocs above survive.
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance.mode,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'DawaFind',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: _generateRoute,
        ),
      ),
    );
  }

  @visibleForTesting
  static Route<dynamic> debugGenerateRoute(RouteSettings settings) =>
      _generateRoute(settings);

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);

      case AppRoutes.onboarding1:
        return _page(const Onboarding1Screen(), settings);

      case AppRoutes.onboarding2:
        return _page(const Onboarding2Screen(), settings);

      case AppRoutes.login:
        return _page(const LoginScreen(), settings);

      case AppRoutes.signup:
        return _page(const SignUpScreen(), settings);

      case AppRoutes.homePatient:
        return _page(
          BlocProvider(
            create: (_) => HomeBloc(),
            child: const HomePatientScreen(),
          ),
          settings,
        );

      case AppRoutes.homePharmacist:
        // InventoryBloc rides along so the dashboard can count real stock.
        return _page(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => HomeBloc()),
              BlocProvider(create: (_) => InventoryBloc()),
            ],
            child: const HomePharmacistScreen(),
          ),
          settings,
        );

      case AppRoutes.search:
        return _page(
          BlocProvider(
            create: (_) => SearchBloc(),
            child: const MedicineSearchScreen(),
          ),
          settings,
        );

      case AppRoutes.inventory:
        return _page(
          BlocProvider(
            create: (_) => InventoryBloc(),
            child: const InventoryScreen(),
          ),
          settings,
        );

      case AppRoutes.admin:
        return _page(
          BlocProvider(create: (_) => AdminBloc(), child: const AdminScreen()),
          settings,
        );

      case AppRoutes.pharmacyDetail:
        return _page(
          BlocProvider(
            create: (_) => PharmacyDetailBloc(),
            child: const PharmacyDetailScreen(),
          ),
          settings,
        );

      case AppRoutes.mapView:
        return _page(const MapViewScreen(), settings);

      case AppRoutes.drugNotFound:
        return _page(const DrugNotFoundScreen(), settings);

      case AppRoutes.profile:
        return _page(
          BlocProvider(
            create: (_) => ProfileBloc(),
            child: const ProfileScreen(),
          ),
          settings,
        );

      case AppRoutes.savedPharmacies:
        return _page(
          BlocProvider(
            create: (_) => SavedPharmaciesBloc(),
            child: const SavedPharmaciesScreen(),
          ),
          settings,
        );

      default:
        return _page(const SplashScreen(), settings);
    }
  }

  // Forwarding `settings` is what carries Navigator.pushNamed's `arguments`
  // through to the screen. Without it ModalRoute.of(context).settings is
  // empty and every argument a screen expects arrives null.
  static MaterialPageRoute<void> _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);
}
