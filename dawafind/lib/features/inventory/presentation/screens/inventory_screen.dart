import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/inventory_bloc.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<InventoryBloc>().add(InventoryLoaded());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Inventory',
          style: TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading || state is InventoryInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (state is InventoryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          if (state is InventorySuccess) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text(
                  'No inventory items yet.',
                  style: TextStyle(color: AppColors.greyText),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final item = state.items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medication,
                          color: AppColors.primaryGreen),
                    ),
                    title: Text(
                      '${item.medicineName} ${item.dosage}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    subtitle: Text(
                      '${item.form} · ${item.packSize} · RWF ${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.greyText),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.isOutOfStock
                            ? Colors.red.shade50
                            : item.isLowStock
                                ? Colors.orange.shade50
                                : AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.isOutOfStock
                            ? 'Out of Stock'
                            : item.isLowStock
                                ? 'Low (${item.quantity})'
                                : 'Qty: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.isOutOfStock
                              ? AppColors.error
                              : item.isLowStock
                                  ? Colors.orange
                                  : AppColors.primaryGreen,
                        ),
                      ),
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
