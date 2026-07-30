import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/search_bloc.dart';

class MedicineSearchScreen extends StatefulWidget {
  const MedicineSearchScreen({super.key});

  @override
  State<MedicineSearchScreen> createState() => _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends State<MedicineSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            hintText: 'Search drug name...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: (query) {
            if (query.trim().isEmpty) {
              context.read<SearchBloc>().add(SearchCleared());
            } else {
              context
                  .read<SearchBloc>()
                  .add(SearchQueryChanged(query: query.trim()));
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.white),
            onPressed: () {
              _controller.clear();
              context.read<SearchBloc>().add(SearchCleared());
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        // Cross-fades between the prompt, spinner and results as the user types.
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _bodyFor(context, state),
        ),
      ),
    );
  }

  Widget _bodyFor(BuildContext context, SearchState state) {
    if (state is SearchLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }
    if (state is SearchSuccess) return _resultsList(context, state);
    if (state is SearchEmpty) return _noResultsState();
    if (state is SearchError) {
      return Center(
        key: const ValueKey('error'),
        child: Text(
          state.message,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }
    // SearchInitial — nothing typed yet.
    return _emptyState();
  }

  Widget _emptyState() => const Center(
    key: ValueKey('initial'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search, size: 64, color: AppColors.inactiveGrey),
        SizedBox(height: 12),
        Text(
          'Type a drug name to search',
          style: TextStyle(color: AppColors.greyText, fontSize: 15),
        ),
      ],
    ),
  );

  Widget _noResultsState() => const Center(
    key: ValueKey('none'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off, size: 64, color: AppColors.inactiveGrey),
        SizedBox(height: 12),
        Text(
          'No medicines found',
          style: TextStyle(color: AppColors.greyText, fontSize: 15),
        ),
      ],
    ),
  );

  Widget _resultsList(BuildContext context, SearchSuccess state) =>
      ListView.builder(
        key: const ValueKey('results'),
        padding: const EdgeInsets.all(16),
        itemCount: state.results.length + 1,
        itemBuilder: (context, i) {
          if (i == state.results.length) {
            return TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.drugNotFound),
              icon: const Icon(Icons.info_outline, color: AppColors.primaryGreen),
              label: const Text(
                "Can't find your medicine?",
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            );
          }
          final r = state.results[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: AppColors.primaryGreen,
                ),
              ),
              title: Text(
                '${r.medicineName} ${r.dosage}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              subtitle: Text(
                r.pharmacyName,
                style: const TextStyle(fontSize: 13, color: AppColors.greyText),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RWF ${r.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: r.inStock
                          ? AppColors.lightGreen
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r.inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 11,
                        color: r.inStock
                            ? AppColors.primaryGreen
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.pharmacyDetail,
                arguments: r.pharmacyId,
              ),
            ),
          );
        },
      );
}
