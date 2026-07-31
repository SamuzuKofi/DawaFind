import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../pharmacy/domain/entities/pharmacy_summary_entity.dart';
import '../bloc/home_bloc.dart';

class HomePatientScreen extends StatefulWidget {
  const HomePatientScreen({super.key});

  @override
  State<HomePatientScreen> createState() => _HomePatientScreenState();
}

class _HomePatientScreenState extends State<HomePatientScreen> {
  static const _categories = [
    'Antibiotics',
    'Painkillers',
    'Vitamins',
    'Malaria',
  ];

  // Loaded once here rather than from build(), which reruns on every rebuild
  // and would refetch on each rotation or theme change.
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final greeting = state is HomeReady ? state.userName : '';
          return Column(
            children: [
              _header(context, greeting),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionLabel('Quick Search'),
                    const SizedBox(height: 8),
                    _categoryChips(),
                    const SizedBox(height: 20),
                    _sectionRow('Nearby Pharmacies', AppStrings.viewAll),
                    const SizedBox(height: 8),
                    ..._nearbyPharmacies(context, state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  List<Widget> _nearbyPharmacies(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        ),
      ];
    }
    if (state is HomeError) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ),
      ];
    }
    if (state is HomeReady) {
      if (state.pharmacies.isEmpty) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No pharmacies listed yet.',
                style: TextStyle(color: AppColors.greyText, fontSize: 13),
              ),
            ),
          ),
        ];
      }
      return state.pharmacies.map((p) => _pharmacyCard(context, p)).toList();
    }
    return const [];
  }

  Widget _header(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName.isEmpty ? 'Good morning,' : 'Good morning, $userName',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'What medicine are you looking for?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.searchPlaceholder,
                      style: TextStyle(
                        color: AppColors.inactiveGrey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(Icons.mic_none, color: AppColors.inactiveGrey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChips() => SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _categories[i],
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      );

  Widget _sectionRow(String label, String action) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel(label),
          Text(
            action,
            style:
                const TextStyle(color: AppColors.primaryGreen, fontSize: 13),
          ),
        ],
      );

  Widget _pharmacyCard(BuildContext context, PharmacySummaryEntity p) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.local_pharmacy, color: AppColors.primaryGreen),
          ),
          title: Text(
            p.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          // Distance needs the device location, which the app does not ask
          // for yet, so the address is the useful thing to show meanwhile.
          subtitle: Text(
            p.distanceKm != null
                ? '${p.distanceKm!.toStringAsFixed(1)} km away'
                : p.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.greyText),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (p.averageRating > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 2),
                    Text(
                      p.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right, color: AppColors.greyText),
            ],
          ),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.pharmacyDetail,
            arguments: p.pharmacyId,
          ),
        ),
      );

  Widget _bottomNav(BuildContext context) => BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.inactiveGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.search);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.mapView);
          if (i == 3) Navigator.pushNamed(context, AppRoutes.profile);
        },
      );
}
