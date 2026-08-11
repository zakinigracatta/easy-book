import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/offer_model.dart';

class PromotionManagementScreen extends ConsumerWidget {
  const PromotionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(ownerOffersProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Offers & Promotional Discounts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Create Offer',
              onPressed: () => _showAddOfferModal(context, ref),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.campaign_rounded,
                        color: AppColors.accent, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marketing Promotions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Create promotional offers to boost bookings during off-peak hours.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Promotions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showAddOfferModal(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('New Offer',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              offersAsync.when(
                data: (offers) {
                  if (offers.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.campaign_rounded,
                      title: 'No Active Offers',
                      description:
                          'Create your first promotional offer to attract more clients.',
                      actionLabel: 'Create Offer',
                      onActionTap: () => _showAddOfferModal(context, ref),
                    );
                  }

                  return Column(
                    children: offers.map((o) {
                      final startStr = DateFormat('MMM d').format(o.startDate);
                      final endStr =
                          DateFormat('MMM d, yyyy').format(o.endDate);
                      final isPercent =
                          o.discountType == DiscountType.percentage;

                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    o.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    isPercent
                                        ? '${o.discountValue.toStringAsFixed(0)}% OFF'
                                        : 'AED ${o.discountValue.toStringAsFixed(0)} OFF',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (o.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                o.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded,
                                    size: 14, color: AppColors.textMutedDark),
                                const SizedBox(width: 4),
                                Text(
                                  'Valid: $startStr – $endStr',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => const OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Offers',
                  description: 'Failed to retrieve promotional offers.',
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  void _showAddOfferModal(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final valController = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Special Offer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: titleController,
              label: 'Offer Title (e.g. Summer Weekend Deal)',
              prefixIcon: Icons.campaign_rounded,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: descController,
              label: 'Description',
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: valController,
              label: 'Discount Percentage (%)',
              prefixIcon: Icons.percent_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Publish Offer',
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final newOffer = OfferModel(
                  id: 'off_${DateTime.now().millisecondsSinceEpoch}',
                  businessId: 'b1',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  discountType: DiscountType.percentage,
                  discountValue:
                      double.tryParse(valController.text.trim()) ?? 20.0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 30)),
                );

                await ref.read(ownerRepositoryProvider).saveOffer(newOffer);
                ref.invalidate(ownerOffersProvider);

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offer published successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
