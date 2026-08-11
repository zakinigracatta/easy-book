import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/customer_profile_model.dart';
import '../../providers/owner_providers.dart';

class CustomerProfileModal extends ConsumerStatefulWidget {
  final CustomerProfileModel customer;

  const CustomerProfileModal({super.key, required this.customer});

  @override
  ConsumerState<CustomerProfileModal> createState() =>
      _CustomerProfileModalState();
}

class _CustomerProfileModalState extends ConsumerState<CustomerProfileModal> {
  late TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.customer.ownerNotes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    final lastVisitStr = c.lastVisit != null
        ? DateFormat('MMM d, yyyy').format(c.lastVisit!)
        : 'Never';

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name & Contact
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage:
                      (c.avatarUrl != null && c.avatarUrl!.isNotEmpty)
                          ? NetworkImage(c.avatarUrl!)
                          : null,
                  child: (c.avatarUrl == null || c.avatarUrl!.isEmpty)
                      ? Text(
                          c.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      if (c.email != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          c.email!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Metrics Summary Grid
            Row(
              children: [
                Expanded(
                  child: _metricBox(
                      'Visits', '${c.completedVisits}', AppColors.primaryLight),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricBox(
                      'Total Spent',
                      'AED ${c.totalSpent.toStringAsFixed(0)}',
                      AppColors.success),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricBox(
                      'No-Shows', '${c.noShowCount}', AppColors.warning),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Text('Last Visit: ',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMutedDark)),
                  Text(
                    lastVisitStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),

            if (c.favoriteServices.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Favorite Services',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMutedDark,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: c.favoriteServices.map((srv) {
                  return Chip(
                    backgroundColor: AppColors.bgDark,
                    side: const BorderSide(color: AppColors.glassBorderDark),
                    label: Text(
                      srv,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Private Internal Owner Notes Section
            const Text(
              'Private Owner Notes (Internal Only)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textMutedDark,
              ),
            ),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _notesController,
              label: 'e.g. Likes espresso, sensitive skin, prefers Ahmed.',
              maxLines: 3,
              prefixIcon: Icons.lock_outline_rounded,
            ),

            const SizedBox(height: 20),

            CustomButton(
              text: 'Save Private Notes',
              isLoading: _isSaving,
              onPressed: () async {
                setState(() => _isSaving = true);
                final bizId = ref.read(currentBusinessIdProvider).value ?? '';
                await ref.read(ownerRepositoryProvider).saveCustomerNotes(
                      bizId,
                      c.id,
                      _notesController.text.trim(),
                    );
                ref.invalidate(ownerCustomersProvider);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Private customer notes saved!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderDark),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
