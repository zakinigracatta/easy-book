import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key, this.businessId});

  final String? businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = businessId?.trim() ?? '';
    final businessState = ref.watch(businessDetailProvider(id));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Salon Location & Directions')),
        ),
        body: id.isEmpty
            ? Center(child: Text(context.tr('Business no longer available')))
            : businessState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(context.tr('Could not load this business')),
                ),
                data: (business) {
                  if (business == null) {
                    return Center(
                      child: Text(context.tr('Business no longer available')),
                    );
                  }

                  final address = business.address.trim();
                  final hasCoordinates =
                      business.latitude != 0 || business.longitude != 0;

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        business.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        address.isEmpty
                                            ? context.tr(
                                                'Location information is not available yet.',
                                              )
                                            : address,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (hasCoordinates) ...[
                              const SizedBox(height: 14),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  '${business.latitude.toStringAsFixed(6)}, ${business.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                            if (address.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: address),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr('Address copied'),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded),
                                label: Text(context.tr('Copy address')),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
