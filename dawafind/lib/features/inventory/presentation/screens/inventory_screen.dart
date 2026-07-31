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

  Future<void> _showAddDialog() async {
    final InventoryItemDraft? draft = await showDialog<InventoryItemDraft>(
      context: context,
      builder: (_) => const _AddDrugDialog(),
    );
    if (draft != null && mounted) {
      context.read<InventoryBloc>().add(InventoryItemAdded(item: draft));
    }
  }

  Future<void> _showEditDialog(InventoryItemEntity item) async {
    final _EditResult? result = await showDialog<_EditResult>(
      context: context,
      builder: (_) => _EditDrugDialog(item: item),
    );
    if (result != null && mounted) {
      context.read<InventoryBloc>().add(
        InventoryItemUpdated(
          stockId: item.stockId,
          quantity: result.quantity,
          price: result.price,
          packSize: result.packSize,
        ),
      );
    }
  }

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
}

// ---------- Result type for edit dialog ----------

class _EditResult {
  const _EditResult({
    required this.packSize,
    required this.price,
    required this.quantity,
  });
  final String packSize;
  final double price;
  final int quantity;
}

// ---------- Add dialog ----------

// Using StatefulWidget + plain TextField instead of Form+TextFormField avoids
// the Flutter 3.27+ assertion that fires when _FormScope (Form's InheritedWidget)
// is deactivated before its TextFormField dependents during dialog dismissal.
class _AddDrugDialog extends StatefulWidget {
  const _AddDrugDialog();

  @override
  State<_AddDrugDialog> createState() => _AddDrugDialogState();
}

class _AddDrugDialogState extends State<_AddDrugDialog> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _form = TextEditingController();
  final _packSize = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();

  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    for (final c in [_name, _dosage, _form, _packSize, _price, _qty]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String?>{};
    if (_name.text.trim().isEmpty) errors['name'] = 'Required';
    if (_dosage.text.trim().isEmpty) errors['dosage'] = 'Required';
    if (_form.text.trim().isEmpty) errors['form'] = 'Required';
    if (_packSize.text.trim().isEmpty) errors['packSize'] = 'Required';

    final priceStr = _price.text.trim();
    if (priceStr.isEmpty) {
      errors['price'] = 'Required';
    } else if (double.tryParse(priceStr) == null) {
      errors['price'] = 'Enter a number';
    } else if (double.parse(priceStr) < 0) {
      errors['price'] = 'Cannot be negative';
    }

    final qtyStr = _qty.text.trim();
    if (qtyStr.isEmpty) {
      errors['qty'] = 'Required';
    } else if (int.tryParse(qtyStr) == null) {
      errors['qty'] = 'Enter a whole number';
    } else if (int.parse(qtyStr) < 0) {
      errors['qty'] = 'Cannot be negative';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Drug'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_name, 'name', 'Medicine name'),
            _field(_dosage, 'dosage', 'Dosage (e.g. 500mg)'),
            _field(_form, 'form', 'Form (e.g. Tablet)'),
            _field(_packSize, 'packSize', 'Pack size (e.g. 10 tablets)'),
            _field(
              _price,
              'price',
              'Price (${AppStrings.currency})',
              numeric: true,
            ),
            _field(_qty, 'qty', 'Quantity', integer: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.greyText),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_validate()) {
              Navigator.pop(
                context,
                InventoryItemDraft(
                  medicineName: _name.text.trim(),
                  dosage: _dosage.text.trim(),
                  form: _form.text.trim(),
                  packSize: _packSize.text.trim(),
                  price: double.parse(_price.text.trim()),
                  quantity: int.parse(_qty.text.trim()),
                ),
              );
            }
          },
          child: const Text(
            'Save',
            style: TextStyle(color: AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String key,
    String label, {
    bool numeric = false,
    bool integer = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: numeric || integer
          ? TextInputType.number
          : TextInputType.text,
      onChanged: (_) {
        if (_errors.containsKey(key)) setState(() => _errors.remove(key));
      },
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        errorText: _errors[key],
      ),
    ),
  );
}

// ---------- Edit dialog ----------

class _EditDrugDialog extends StatefulWidget {
  const _EditDrugDialog({required this.item});

  final InventoryItemEntity item;

  @override
  State<_EditDrugDialog> createState() => _EditDrugDialogState();
}

class _EditDrugDialogState extends State<_EditDrugDialog> {
  late final _packSize =
      TextEditingController(text: widget.item.packSize);
  late final _price =
      TextEditingController(text: widget.item.price.toStringAsFixed(0));
  late final _qty =
      TextEditingController(text: '${widget.item.quantity}');

  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    _packSize.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String?>{};
    if (_packSize.text.trim().isEmpty) errors['packSize'] = 'Required';

    final priceStr = _price.text.trim();
    if (priceStr.isEmpty) {
      errors['price'] = 'Required';
    } else if (double.tryParse(priceStr) == null) {
      errors['price'] = 'Enter a number';
    } else if (double.parse(priceStr) < 0) {
      errors['price'] = 'Cannot be negative';
    }

    final qtyStr = _qty.text.trim();
    if (qtyStr.isEmpty) {
      errors['qty'] = 'Required';
    } else if (int.tryParse(qtyStr) == null) {
      errors['qty'] = 'Enter a whole number';
    } else if (int.parse(qtyStr) < 0) {
      errors['qty'] = 'Cannot be negative';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Edit ${widget.item.medicineName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_packSize, 'packSize', 'Pack size'),
            _field(
              _price,
              'price',
              'Price (${AppStrings.currency})',
              numeric: true,
            ),
            _field(_qty, 'qty', 'Quantity', integer: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.greyText),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_validate()) {
              Navigator.pop(
                context,
                _EditResult(
                  packSize: _packSize.text.trim(),
                  price: double.parse(_price.text.trim()),
                  quantity: int.parse(_qty.text.trim()),
                ),
              );
            }
          },
          child: const Text(
            'Save',
            style: TextStyle(color: AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String key,
    String label, {
    bool numeric = false,
    bool integer = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: numeric || integer
          ? TextInputType.number
          : TextInputType.text,
      onChanged: (_) {
        if (_errors.containsKey(key)) setState(() => _errors.remove(key));
      },
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        errorText: _errors[key],
      ),
    ),
  );
}
