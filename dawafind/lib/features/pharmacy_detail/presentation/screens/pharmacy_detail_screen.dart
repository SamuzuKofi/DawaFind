import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/pharmacy_detail_bloc.dart';

class PharmacyDetailScreen extends StatelessWidget {
  const PharmacyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The pharmacyId is passed as a route argument from the search or saved
    // pharmacies screen. Dispatch the load event immediately.
    final pharmacyId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    context
        .read<PharmacyDetailBloc>()
        .add(PharmacyDetailRequested(pharmacyId: pharmacyId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<PharmacyDetailBloc, PharmacyDetailState>(
        builder: (context, state) {
          if (state is PharmacyDetailLoading ||
              state is PharmacyDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (state is PharmacyDetailError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          if (state is PharmacyDetailReady) {
            return _buildDetail(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, PharmacyDetailReady state) {
    final pharmacy = state.pharmacy;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          pharmacy.name,
          style: const TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pharmacy.address,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Open',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pharmacy.phone,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        ' (${pharmacy.ratingCount})',
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Available Drugs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          ...pharmacy.stock.map(
            (d) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: d.inStock ? AppColors.primaryGreen : AppColors.error,
                ),
                title: Text(
                  '${d.medicineName} ${d.dosage}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  d.inStock
                      ? 'RWF ${d.price.toStringAsFixed(0)}'
                      : 'Out of Stock',
                  style: TextStyle(
                    color: d.inStock ? AppColors.primaryGreen : AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.mapView),
                icon: const Icon(
                  Icons.directions,
                  color: AppColors.primaryGreen,
                ),
                label: const Text(
                  'Directions',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {},
                icon: const Icon(Icons.call, color: AppColors.white),
                label: const Text(
                  'Call',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
