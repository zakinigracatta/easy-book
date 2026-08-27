import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../theme/app_colors.dart';
import 'service_card.dart';
import '../../../l10n/l10n.dart';

class ServiceCategorySection extends StatefulWidget {
  final List<ServiceModel> services;
  final List<String> selectedServiceIds;
  final Function(ServiceModel) onServiceSelect;

  const ServiceCategorySection({
    super.key,
    required this.services,
    required this.selectedServiceIds,
    required this.onServiceSelect,
  });

  @override
  State<ServiceCategorySection> createState() => _ServiceCategorySectionState();
}

class _ServiceCategorySectionState extends State<ServiceCategorySection> {
  static const _allCategoryKey = '__all__';
  String _selectedCategory = _allCategoryKey;

  @override
  Widget build(BuildContext context) {
    if (widget.services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.design_services_outlined,
                size: 48, color: AppColors.textMutedDark),
            const SizedBox(height: 12),
            Text(
              l10nOf(context).noServicesAvailableNow,
              style:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Extract categories
    final categoriesMap = <String, String>{};
    categoriesMap[_allCategoryKey] = l10nOf(context).all;
    for (final s in widget.services) {
      categoriesMap[s.categoryId] = s.categoryName;
    }
    final categoryKeys = categoriesMap.keys.toList();

    // Filter services
    final filteredServices = widget.services.where((s) {
      if (_selectedCategory == _allCategoryKey) return true;
      return s.categoryId == _selectedCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pills Filter
        if (categoryKeys.length > 2) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoryKeys.map((catId) {
                final catName = categoriesMap[catId]!;
                final isSelected = _selectedCategory == catId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(catName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = catId;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.cardDark,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondaryDark,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.glassBorderDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Services List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredServices.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final service = filteredServices[index];
            final isSelected = widget.selectedServiceIds.contains(service.id);
            return ServiceCard(
              service: service,
              isSelected: isSelected,
              onBookTap: () => widget.onServiceSelect(service),
            );
          },
        ),
      ],
    );
  }
}
