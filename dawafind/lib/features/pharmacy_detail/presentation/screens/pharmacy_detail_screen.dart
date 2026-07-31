import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/pharmacy_detail_bloc.dart';

class PharmacyDetailScreen extends StatefulWidget {
  const PharmacyDetailScreen({super.key});

  @override
  State<PharmacyDetailScreen> createState() => _PharmacyDetailScreenState();
}

class _PharmacyDetailScreenState extends State<PharmacyDetailScreen> {
  // Loading is kicked off once here rather than from build(), which reruns on
  // every rebuild — a rotation or theme change would otherwise refetch the
  // whole pharmacy.
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;

    // Passed as a route argument by whichever screen opened this one.
    final pharmacyId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    context.read<PharmacyDetailBloc>().add(
      PharmacyDetailRequested(pharmacyId: pharmacyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocConsumer<PharmacyDetailBloc, PharmacyDetailState>(
        // Toggling a bookmark only flips an icon, which is easy to miss on a
        // small screen, so the outcome is confirmed in words too.
        listenWhen: (previous, current) =>
            previous is PharmacyDetailReady &&
            current is PharmacyDetailReady &&
            previous.isSaved != current.isSaved,
        listener: (context, state) {
          final saved = (state as PharmacyDetailReady).isSaved;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  saved ? 'Pharmacy saved.' : 'Removed from saved pharmacies.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
        },
        builder: (context, state) {
          if (state is PharmacyDetailLoading ||
              state is PharmacyDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (state is PharmacyDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
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

  /// Lets the signed-in user leave their own score. Submitting refreshes the
  /// whole detail view, so the average and count above update in place.
  Widget _ratingCard(BuildContext context, PharmacyDetailReady state) {
    final myRating = state.myRating;
    final pharmacyId = state.pharmacy.pharmacyId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                if (myRating != null)
                  TextButton(
                    onPressed: () => context.read<PharmacyDetailBloc>().add(
                      PharmacyDetailRatingRemoved(pharmacyId: pharmacyId),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) {
                final score = i + 1;
                final filled = myRating != null && score <= myRating;
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  tooltip: '$score star${score == 1 ? '' : 's'}',
                  onPressed: () => context.read<PharmacyDetailBloc>().add(
                    PharmacyDetailRatingSubmitted(
                      pharmacyId: pharmacyId,
                      score: score.toDouble(),
                    ),
                  ),
                  icon: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: filled ? Colors.amber : AppColors.inactiveGrey,
                    size: 30,
                  ),
                );
              }),
            ),
            Text(
              myRating == null
                  ? 'Tap a star to rate this pharmacy.'
                  : 'You rated this pharmacy ${myRating.toStringAsFixed(0)} of 5.',
              style: const TextStyle(color: AppColors.greyText, fontSize: 12),
            ),
          ],
        ),
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
        actions: [
          IconButton(
            tooltip: state.isSaved ? 'Remove from saved' : 'Save pharmacy',
            onPressed: () => context.read<PharmacyDetailBloc>().add(
              PharmacyDetailSaveToggled(pharmacyId: pharmacy.pharmacyId),
            ),
            icon: Icon(
              state.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.white,
            ),
          ),
        ],
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
          _ratingCard(context, state),
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
                      ? '${AppStrings.currency} ${d.price.toStringAsFixed(0)}'
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
