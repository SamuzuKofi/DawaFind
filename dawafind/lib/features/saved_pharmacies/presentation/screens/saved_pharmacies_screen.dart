import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/saved_pharmacies_bloc.dart';

class SavedPharmaciesScreen extends StatefulWidget {
  const SavedPharmaciesScreen({super.key});

  @override
  State<SavedPharmaciesScreen> createState() => _SavedPharmaciesScreenState();
}

class _SavedPharmaciesScreenState extends State<SavedPharmaciesScreen> {
  // Loaded once here rather than from build(), which reruns on every rebuild
  // and would refetch the list on each rotation or theme change.
  @override
  void initState() {
    super.initState();
    context.read<SavedPharmaciesBloc>().add(SavedPharmaciesLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Saved Pharmacies',
          style: TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: BlocBuilder<SavedPharmaciesBloc, SavedPharmaciesState>(
        builder: (context, state) {
          if (state is SavedPharmaciesLoading ||
              state is SavedPharmaciesInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (state is SavedPharmaciesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          if (state is SavedPharmaciesReady) {
            if (state.pharmacies.isEmpty) {
              return const Center(
                child: Text(
                  'No saved pharmacies yet.',
                  style: TextStyle(color: AppColors.greyText),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.pharmacies.length,
              itemBuilder: (context, i) {
                final p = state.pharmacies[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.lightGreen,
                      child: Icon(
                        Icons.local_pharmacy,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    subtitle: Text(
                      p.distanceKm != null
                          ? '${p.distanceKm!.toStringAsFixed(1)} km · ${p.address}'
                          : p.address,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.greyText),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              p.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.darkText),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.greyText),
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.pharmacyDetail,
                      arguments: p.pharmacyId,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
