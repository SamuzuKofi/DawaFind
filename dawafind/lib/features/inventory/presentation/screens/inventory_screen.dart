import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../bloc/inventory_bloc.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatched once here rather than in build(), which would re-fire on
    // every rebuild.
    context.read<InventoryBloc>().add(InventoryLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Inventory'),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Drug'),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        // Failures surface as a snack bar so the user always gets feedback.
        listener: (context, state) {
          if (state is InventoryError) {
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
          if (state is InventoryInitial || state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! InventorySuccess) {
            return _message('Could not load your inventory.');
          }
          if (state.items.isEmpty) {
            return _message('No drugs yet. Tap Add Drug to create one.');
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<InventoryBloc>().add(InventoryLoaded()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.items.length,
              itemBuilder: (context, i) => _itemCard(state.items[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.greyText, fontSize: 15),
      ),
    ),
  );

  Widget _itemCard(InventoryItemEntity item) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      isThreeLine: true,
      leading: CircleAvatar(
        backgroundColor: AppColors.lightGreen,
        child: Icon(Icons.medication, color: _statusColor(item)),
      ),
      title: Text(
        '${item.medicineName} ${item.dosage}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.form} · ${item.packSize} · ${AppStrings.currency} ${item.price.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            _statusLabel(item),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _statusColor(item),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        onPressed: () => _confirmDelete(item),
      ),
      onTap: () => _showEditDialog(item),
    ),
  );

  // Status is derived from quantity rather than stored, matching the entity.
  Color _statusColor(InventoryItemEntity item) {
    if (item.isOutOfStock) return AppColors.error;
    if (item.isLowStock) return Colors.orange;
    return AppColors.primaryGreen;
  }

  String _statusLabel(InventoryItemEntity item) {
    if (item.isOutOfStock) return 'Out of stock';
    if (item.isLowStock) return 'Low stock · ${item.quantity} left';
    return '${item.quantity} in stock';
  }

  // ---------- Create ----------

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final dosage = TextEditingController();
    final form = TextEditingController();
    final packSize = TextEditingController();
    final price = TextEditingController();
    final quantity = TextEditingController();

    final bool? save = await _formDialog(
      title: 'Add Drug',
      formKey: formKey,
      fields: [
        _field(name, 'Medicine name'),
        _field(dosage, 'Dosage (e.g. 500mg)'),
        _field(form, 'Form (e.g. Tablet)'),
        _field(packSize, 'Pack size (e.g. 10 tablets)'),
        _field(price, 'Price (${AppStrings.currency})', numeric: true),
        _field(quantity, 'Quantity', integer: true),
      ],
    );

    if (save == true && mounted) {
      context.read<InventoryBloc>().add(
        InventoryItemAdded(
          item: InventoryItemDraft(
            medicineName: name.text.trim(),
            dosage: dosage.text.trim(),
            form: form.text.trim(),
            packSize: packSize.text.trim(),
            price: double.parse(price.text.trim()),
            quantity: int.parse(quantity.text.trim()),
          ),
        ),
      );
    }
    for (final c in [name, dosage, form, packSize, price, quantity]) {
      c.dispose();
    }
  }

  // ---------- Update ----------

  Future<void> _showEditDialog(InventoryItemEntity item) async {
    final formKey = GlobalKey<FormState>();
    final packSize = TextEditingController(text: item.packSize);
    final price = TextEditingController(text: item.price.toStringAsFixed(0));
    final quantity = TextEditingController(text: '${item.quantity}');

    final bool? save = await _formDialog(
      title: 'Edit ${item.medicineName}',
      formKey: formKey,
      fields: [
        _field(packSize, 'Pack size'),
        _field(price, 'Price (${AppStrings.currency})', numeric: true),
        _field(quantity, 'Quantity', integer: true),
      ],
    );

    if (save == true && mounted) {
      context.read<InventoryBloc>().add(
        InventoryItemUpdated(
          stockId: item.stockId,
          quantity: int.parse(quantity.text.trim()),
          price: double.parse(price.text.trim()),
          packSize: packSize.text.trim(),
        ),
      );
    }
    for (final c in [packSize, price, quantity]) {
      c.dispose();
    }
  }

  // ---------- Delete ----------

  Future<void> _confirmDelete(InventoryItemEntity item) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete drug?'),
        content: Text(
          '${item.medicineName} ${item.dosage} will be removed from your inventory.',
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
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      context.read<InventoryBloc>().add(
        InventoryItemDeleted(itemId: item.stockId),
      );
    }
  }

  // ---------- Shared dialog pieces ----------

  /// One dialog shell reused by add and edit so both look and validate the same.
  Future<bool?> _formDialog({
    required String title,
    required GlobalKey<FormState> formKey,
    required List<Widget> fields,
  }) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: fields),
        ),
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
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(dialogContext, true);
            }
          },
          child: const Text(
            'Save',
            style: TextStyle(color: AppColors.primaryGreen),
          ),
        ),
      ],
    ),
  );

  // `integer` fields are parsed with int.parse when the form is submitted,
  // and int.parse rejects anything with a decimal point. Validating those
  // with double.tryParse would let "10.5" through the form and then throw,
  // so whole-number fields are checked with int.tryParse instead.
  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    bool integer = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: numeric || integer
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(labelText: label, isDense: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (integer) {
          final parsed = int.tryParse(value.trim());
          if (parsed == null) return 'Enter a whole number';
          if (parsed < 0) return 'Cannot be negative';
          return null;
        }
        if (numeric) {
          final parsed = double.tryParse(value.trim());
          if (parsed == null) return 'Enter a number';
          if (parsed < 0) return 'Cannot be negative';
        }
        return null;
      },
    ),
  );
}
