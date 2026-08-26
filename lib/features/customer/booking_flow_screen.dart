import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/custom_button.dart';
import '../../services/navigation_service.dart';
import '../../models/booking_model.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;
  String _selectedStaff = 'Marcus Vance';
  String _selectedTimeSlot = '10:00 AM';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isBooking = false;

  final List<Map<String, String>> _staffList = [
    {
      'name': 'Marcus Vance',
      'title': 'Master Barber & Stylist',
      'rating': '4.9'
    },
    {'name': 'Elena Rostova', 'title': 'Senior Hair Colorist', 'rating': '4.8'},
    {'name': 'David Kim', 'title': 'Spa Specialist', 'rating': '5.0'},
  ];

  Future<void> _confirmBooking() async {
    debugPrint('BOOKING_CONFIRM_PRESSED');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      NavigationService().setPendingRoute('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in to complete your booking.')),
      );
      context.push('/login');
      return;
    }

    const businessId = 'b1';
    const serviceId = 's1';
    const staffId = 'st1';

    int hour = 10;
    int minute = 0;
    try {
      final parts = _selectedTimeSlot.split(' ');
      final timeParts = parts[0].split(':');
      hour = int.parse(timeParts[0]);
      minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }
    } catch (e) {
      debugPrint('Error parsing time slot: $e');
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
    final endDateTime = startDateTime.add(const Duration(minutes: 45));
    final slotLockId =
        '${businessId}_${staffId}_${startDateTime.millisecondsSinceEpoch}';

    debugPrint('BOOKING_CREATE_START');
    debugPrint('booking businessId: $businessId');
    debugPrint('serviceId: $serviceId');
    debugPrint('staffId: $staffId');
    debugPrint('startDateTime: ${startDateTime.toIso8601String()}');
    debugPrint('slotLockId: $slotLockId');

    final booking = BookingModel(
      id: '',
      customerId: user.uid,
      customerName: user.displayName ?? user.email ?? 'Valued Customer',
      businessId: businessId,
      businessName: 'Executive Barber Lounge',
      serviceId: serviceId,
      serviceName: 'Luxury Haircut & Beard Sculpting',
      servicePrice: 65.0,
      staffId: staffId,
      staffName: _selectedStaff,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      status: BookingStatus.pending,
      slotLockId: slotLockId,
    );

    setState(() => _isBooking = true);
    try {
      final result =
          await ref.read(appointmentsProvider.notifier).createBooking(booking);
      debugPrint('BOOKING_CREATE_SUCCESS: ${result.id}');
      if (mounted) {
        context.go('/booking-success');
      }
    } catch (e, st) {
      debugPrint('BOOKING_CREATE_ERROR: $e\n$st');
      if (mounted) {
        final errText = e is FirebaseException
            ? '[${e.code}] ${e.message}'
            : e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0 && context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Book Appointment'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: Colors.grey.shade200,
                color: Theme.of(context).primaryColor,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _currentStep == 0
                      ? _buildSelectStaffStep()
                      : _currentStep == 1
                          ? _buildSelectDateStep()
                          : _buildSummaryStep(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          isOutlined: true,
                          onPressed: () => setState(() => _currentStep--),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: _currentStep == 2 ? 'Confirm & Pay \$65' : 'Next',
                        isLoading: _isBooking,
                        onPressed: () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            _confirmBooking();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectStaffStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Choose Specialist',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Select your preferred specialist or staff member.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        ..._staffList.map((s) {
          final isSelected = _selectedStaff == s['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedStaff = s['name']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(s['name']![0],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['name']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(s['title']!,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(s['rating']!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectDateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Date & Time',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Pick a convenient date and available time slot.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
          onDateChanged: (d) => setState(() => _selectedDate = d),
        ),
        const SizedBox(height: 16),
        const Text('Available Time Slots',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.defaultTimeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedTimeSlot = slot),
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Review & Confirm',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Verify your appointment details before proceeding.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildDetailRow('Business', 'Executive Barber Lounge'),
              const Divider(height: 24),
              _buildDetailRow('Service', 'Luxury Haircut & Beard Sculpting'),
              const Divider(height: 24),
              _buildDetailRow('Specialist', _selectedStaff),
              const Divider(height: 24),
              _buildDetailRow('Time & Date',
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at $_selectedTimeSlot'),
              const Divider(height: 24),
              _buildDetailRow('Total Amount', '\$65.00', isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 17 : 14,
            color: isBold ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }
}
