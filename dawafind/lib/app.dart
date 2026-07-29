import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/home/presentation/screens/home_patient_screen.dart';
import 'features/home/presentation/screens/home_pharmacist_screen.dart';
import 'features/search/presentation/screens/medicine_search_screen.dart';
import 'features/inventory/presentation/screens/inventory_screen.dart';
import 'features/admin/presentation/screens/admin_screen.dart';

class DawaFindApp extends StatelessWidget {
  const DawaFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // AuthBloc is provided here so it is available throughout the app.
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'DawaFind',
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        initialRoute: AppRoutes.login,
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
      case AppRoutes.login:
        return _page(const LoginScreen());

      case AppRoutes.signup:
        return _page(const SignUpScreen());

      case AppRoutes.homePatient:
        return _page(const HomePatientScreen());

      case AppRoutes.homePharmacist:
        return _page(const HomePharmacistScreen());

      case AppRoutes.search:
        // SearchBloc is provided here so it is scoped to this route only.
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

      default:
        return _page(const LoginScreen());
    }
  }

  static MaterialPageRoute<void> _page(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
