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
import '../../l10n/l10n.dart';

class PromotionManagementScreen extends ConsumerWidget {
  const PromotionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: Text(l10n.offersPromotionalDiscounts),
          actions: [
            IconButton(
              icon: Icon(Icons.add_rounded),
              tooltip: l10n.createOffer,
              onPressed: () => _showAddOfferModal(context, ref),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.campaign_rounded,
                        color: AppColors.accent, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.marketingPromotions,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            l10n.marketingPromotionsDescription,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.activePromotions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
                    icon: Icon(Icons.add_rounded, size: 16),
                    label: Text(l10n.newOffer,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              offersAsync.when(
                data: (offers) {
                  if (offers.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.campaign_rounded,
                      title: l10n.noActiveOffers,
                      description: l10n.createFirstOfferDescription,
                      actionLabel: l10n.createOffer,
                      onActionTap: () => _showAddOfferModal(context, ref),
                    );
                  }

                  return Column(
                    children: offers.map((o) {
                      final locale =
                          Localizations.localeOf(context).toLanguageTag();
                      final startStr =
                          DateFormat('MMM d', locale).format(o.startDate);
                      final endStr =
                          DateFormat('MMM d, yyyy', locale).format(o.endDate);
                      final isPercent =
                          o.discountType == DiscountType.percentage;

                      return GlassCard(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    o.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
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
                                        ? l10n.percentOff(
                                            o.discountValue.toStringAsFixed(0))
                                        : l10n.amountOff(
                                            o.discountValue.toStringAsFixed(0)),
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (o.description.isNotEmpty) ...[
                              SizedBox(height: 6),
                              Text(
                                o.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.date_range_rounded,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                SizedBox(width: 4),
                                Text(
                                  l10n.validDateRange(startStr, endStr),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                loading: () => Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: l10n.unableToLoadOffers,
                  description: l10n.offersLoadFailed,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  void _showAddOfferModal(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final valController = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
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
            Text(
              l10n.createSpecialOffer,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: titleController,
              label: l10n.offerTitleHint,
              prefixIcon: Icons.campaign_rounded,
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: descController,
              label: l10n.description,
              prefixIcon: Icons.notes_rounded,
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: valController,
              label: l10n.discountPercentage,
              prefixIcon: Icons.percent_rounded,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: l10n.publishOffer,
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final bizId = ref.read(currentBusinessIdProvider).value ?? '';
                final newOffer = OfferModel(
                  id: 'off_${DateTime.now().millisecondsSinceEpoch}',
                  businessId: bizId,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  discountType: DiscountType.percentage,
                  discountValue:
                      double.tryParse(valController.text.trim()) ?? 20.0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(Duration(days: 30)),
                );

                await ref.read(ownerRepositoryProvider).saveOffer(newOffer);
                ref.invalidate(ownerOffersProvider);
                if (!ctx.mounted || !context.mounted) return;

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.offerPublished),
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
