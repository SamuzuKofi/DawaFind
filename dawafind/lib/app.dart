import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
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
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'DawaFind',
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  ThemeData _theme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
        ),
        useMaterial3: true,
      );

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen());

      case AppRoutes.onboarding1:
        return _page(const Onboarding1Screen());

      case AppRoutes.onboarding2:
        return _page(const Onboarding2Screen());

      case AppRoutes.login:
        return _page(const LoginScreen());

      case AppRoutes.signup:
        return _page(const SignUpScreen());

      case AppRoutes.homePatient:
        return _page(const HomePatientScreen());

      case AppRoutes.homePharmacist:
        return _page(const HomePharmacistScreen());

      case AppRoutes.search:
        return _page(
          BlocProvider(
            create: (_) => SearchBloc(),
            child: const MedicineSearchScreen(),
          ),
        );

      case AppRoutes.inventory:
        return _page(
          BlocProvider(
            create: (_) => InventoryBloc(),
            child: const InventoryScreen(),
          ),
        );

      case AppRoutes.admin:
        return _page(
          BlocProvider(
            create: (_) => AdminBloc(),
            child: const AdminScreen(),
          ),
        );

      case AppRoutes.pharmacyDetail:
        return _page(const PharmacyDetailScreen());

      case AppRoutes.mapView:
        return _page(const MapViewScreen());

      case AppRoutes.drugNotFound:
        return _page(const DrugNotFoundScreen());

      case AppRoutes.profile:
        return _page(const ProfileScreen());

      case AppRoutes.savedPharmacies:
        return _page(const SavedPharmaciesScreen());

      default:
        return _page(const SplashScreen());
    }
  }

  static MaterialPageRoute<void> _page(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
