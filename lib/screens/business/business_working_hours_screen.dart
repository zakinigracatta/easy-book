import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../providers/owner_providers.dart';
import '../../models/working_hours_model.dart';
import '../../models/business_model.dart';

class BusinessWorkingHoursScreen extends ConsumerStatefulWidget {
  const BusinessWorkingHoursScreen({super.key});

  @override
  ConsumerState<BusinessWorkingHoursScreen> createState() =>
      _BusinessWorkingHoursScreenState();
}

class _BusinessWorkingHoursScreenState
    extends ConsumerState<BusinessWorkingHoursScreen> {
  final Map<String, ({bool isClosed, String open, String close})> _hoursMap = {
    'Monday': (isClosed: false, open: '09:00 AM', close: '10:00 PM'),
    'Tuesday': (isClosed: false, open: '09:00 AM', close: '10:00 PM'),
    'Wednesday': (isClosed: false, open: '09:00 AM', close: '10:00 PM'),
    'Thursday': (isClosed: false, open: '09:00 AM', close: '10:00 PM'),
    'Friday': (isClosed: false, open: '02:00 PM', close: '11:00 PM'),
    'Saturday': (isClosed: false, open: '09:00 AM', close: '10:00 PM'),
    'Sunday': (isClosed: true, open: '09:00 AM', close: '06:00 PM'),
  };

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(ownerBusinessProvider);

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
          title: const Text('Business Working Hours'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.access_time_filled_rounded,
                        color: AppColors.primaryLight, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operating Hours Configuration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Set regular business operating hours for each day of the week.',
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

              const SizedBox(height: 16),

              // Days of week
              ..._hoursMap.entries.map((entry) {
                final day = entry.key;
                final data = entry.value;

                return GlassCard(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.isClosed
                                ? 'Closed'
                                : '${data.open} – ${data.close}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: data.isClosed
                                  ? AppColors.error
                                  : AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            data.isClosed ? 'Closed' : 'Open',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: data.isClosed
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          Switch(
                            value: !data.isClosed,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _hoursMap[day] = (
                                  isClosed: !val,
                                  open: data.open,
                                  close: data.close,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              CustomButton(
                text: 'Save Working Hours',
                isLoading: _isLoading,
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    final currentBiz = businessAsync.value;
                    if (currentBiz != null) {
                      final scheduleMap = <String, DailyHours>{};
                      _hoursMap.forEach((day, h) {
                        scheduleMap[day] = DailyHours(
                          dayName: day,
                          openTime: h.open,
                          closeTime: h.close,
                          isClosed: h.isClosed,
                        );
                      });

                      final updatedBiz = BusinessModel(
                        id: currentBiz.id,
                        name: currentBiz.name,
                        category: currentBiz.category,
                        address: currentBiz.address,
                        rating: currentBiz.rating,
                        reviewCount: currentBiz.reviewCount,
                        imageUrl: currentBiz.imageUrl,
                        isVerified: currentBiz.isVerified,
                        description: currentBiz.description,
                        ownerId: currentBiz.ownerId,
                        phone: currentBiz.phone,
                        website: currentBiz.website,
                        galleryUrls: currentBiz.galleryUrls,
                        isActive: currentBiz.isActive,
                        workingHours: WorkingHoursModel(schedule: scheduleMap),
                      );

                      await ref
                          .read(ownerBusinessProvider.notifier)
                          .updateBusiness(updatedBiz);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Business working hours updated!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        context.pop();
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update working hours: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
