import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class MedicineSearchScreen extends StatefulWidget {
  const MedicineSearchScreen({super.key});

  @override
  State<MedicineSearchScreen> createState() => _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends State<MedicineSearchScreen> {
  final _controller = TextEditingController();
  final _results = [
    {
      'drug': 'Amoxicillin 500mg',
      'pharmacy': 'Dawa Pharmacy',
      'price': 'RWF 2,300',
      'available': true,
    },
    {
      'drug': 'Amoxicillin 250mg',
      'pharmacy': 'Health Plus Pharmacy',
      'price': 'RWF 1,800',
      'available': true,
    },
    {
      'drug': 'Amoxicillin 125mg',
      'pharmacy': 'City Pharma',
      'price': 'RWF 1,500',
      'available': false,
    },
  ];

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
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.white),
            onPressed: () => _controller.clear(),
          ),
        ],
      ),
      body: _controller.text.isEmpty ? _emptyState() : _resultsList(context),
    );
  }

  Widget _emptyState() => const Center(
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

  Widget _resultsList(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _results.length + 1,
    itemBuilder: (context, i) {
      if (i == _results.length) {
        return TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.drugNotFound),
          icon: const Icon(Icons.info_outline, color: AppColors.primaryGreen),
          label: const Text(
            "Can't find your medicine?",
            style: TextStyle(color: AppColors.primaryGreen),
          ),
        );
      }
      final r = _results[i];
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            r['drug'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          subtitle: Text(
            r['pharmacy'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.greyText),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r['price'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (r['available'] as bool)
                      ? AppColors.lightGreen
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (r['available'] as bool) ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    color: (r['available'] as bool)
                        ? AppColors.primaryGreen
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => Navigator.pushNamed(context, AppRoutes.pharmacyDetail),
        ),
      );
    },
  );
}
