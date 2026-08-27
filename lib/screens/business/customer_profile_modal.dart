import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/customer_profile_model.dart';
import '../../providers/owner_providers.dart';
import '../../l10n/l10n.dart';

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
    final l10n = l10nOf(context);
    final c = widget.customer;
    final lastVisitStr = c.lastVisit != null
        ? DateFormat(
            'MMM d, yyyy',
            Localizations.localeOf(context).toLanguageTag(),
          ).format(c.lastVisit!)
        : l10n.never;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        c.phone,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (c.email != null) ...[
                        SizedBox(height: 2),
                        Text(
                          c.email!,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _metricBox(l10n.visits, '${c.completedVisits}',
                      AppColors.primaryLight),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _metricBox(
                      l10n.totalSpent,
                      'AED ${c.totalSpent.toStringAsFixed(0)}',
                      AppColors.success),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _metricBox(
                      l10n.noShows, '${c.noShowCount}', AppColors.warning),
                ),
              ],
            ),
            SizedBox(height: 16),
            GlassCard(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 18, color: AppColors.accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.lastVisit(lastVisitStr),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (c.favoriteServices.isNotEmpty) ...[
              SizedBox(height: 14),
              Text(
                l10n.favoriteServices,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: c.favoriteServices.map((srv) {
                  return Chip(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outline),
                    label: Text(
                      srv,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 16),
            Text(
              l10n.privateOwnerNotes,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 6),
            CustomTextField(
              controller: _notesController,
              label: l10n.privateNotesHint,
              maxLines: 3,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: l10n.savePrivateNotes,
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
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.privateNotesSaved),
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

  Widget _metricBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
