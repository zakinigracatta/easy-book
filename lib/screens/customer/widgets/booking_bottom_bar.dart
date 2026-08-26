import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/business_model.dart';
import '../../../providers/app_providers.dart';
import '../../../services/auth_guard.dart';
import '../../../theme/app_colors.dart';

class BookingBottomBar extends ConsumerWidget {
  final BusinessModel business;
  final VoidCallback? onBookNowTap;

  BookingBottomBar({
    super.key,
    required this.business,
    this.onBookNowTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final count = draft.selectedServicesCount;
    final totalPrice = draft.totalPrice;
    final totalDuration = draft.totalDurationMinutes;
    final canBook = business.isActive &&
        business.acceptingBookings &&
        business.businessStatus == 'open';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).colorScheme.surface : AppColors.cardLight;
    final borderColor =
        isDark ? Theme.of(context).dividerColor : AppColors.glassBorderLight;
    final mutedColor =
        isDark ? Theme.of(context).colorScheme.onSurfaceVariant : AppColors.textMutedLight;
    final secondaryColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textSecondaryLight;

    final hasSelection = count > 0;
    final buttonText = hasSelection ? 'Continue' : 'Book Now';

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.shadowDark
                : AppColors.shadowLight.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasSelection) ...[
                      Text(
                        count == 1
                            ? '1 ${context.tr('service selected')}'
                            : '$count ${context.tr('services selected')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              CurrencyFormatter.format(totalPrice),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•  $totalDuration ${context.tr('min')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        business.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        context.tr(
                          canBook
                              ? 'Select a service or tap Book Now'
                              : 'Online booking is currently unavailable',
                        ),
                        style: TextStyle(fontSize: 12, color: mutedColor),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: canBook
                    ? () async {
                        if (onBookNowTap != null) {
                          onBookNowTap!();
                          return;
                        }

                        final currentDraft = ref.read(bookingDraftProvider);
                        ref.read(bookingDraftProvider.notifier).state =
                            currentDraft.copyWith(
                          businessId: business.id,
                          businessName: business.name,
                        );

                        final allowed = await requireLogin(
                          context,
                          targetRoute: '/booking-service',
                        );
                        if (allowed && context.mounted) {
                          context.push('/booking-service');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBook ? AppColors.primary : cardColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: canBook ? 4 : 0,
                ),
                child: Text(
                  context.tr(canBook ? buttonText : 'Unavailable'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
