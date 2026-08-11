import 'package:flutter/material.dart';
import '../../models/booking_model.dart';

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final bool isCompact;

  const BookingStatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStatusStyle(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: style.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: TextStyle(
              color: style.textColor,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color bgColor, Color textColor, Color borderColor})
      _getStatusStyle(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return (
          label: 'Pending',
          bgColor: const Color(0x26F59E0B),
          textColor: const Color(0xFFFBBF24),
          borderColor: const Color(0x66F59E0B),
        );
      case BookingStatus.confirmed:
        return (
          label: 'Confirmed',
          bgColor: const Color(0x263B82F6),
          textColor: const Color(0xFF60A5FA),
          borderColor: const Color(0x663B82F6),
        );
      case BookingStatus.arrived:
        return (
          label: 'Arrived',
          bgColor: const Color(0x268B5CF6),
          textColor: const Color(0xFFA78BFA),
          borderColor: const Color(0x668B5CF6),
        );
      case BookingStatus.inProgress:
        return (
          label: 'In Progress',
          bgColor: const Color(0x26A855F7),
          textColor: const Color(0xFFC084FC),
          borderColor: const Color(0x66A855F7),
        );
      case BookingStatus.completed:
        return (
          label: 'Completed',
          bgColor: const Color(0x2610B981),
          textColor: const Color(0xFF34D399),
          borderColor: const Color(0x6610B981),
        );
      case BookingStatus.cancelled:
        return (
          label: 'Cancelled',
          bgColor: const Color(0x26EF4444),
          textColor: const Color(0xFFF87171),
          borderColor: const Color(0x66EF4444),
        );
      case BookingStatus.noShow:
        return (
          label: 'No Show',
          bgColor: const Color(0x2664748B),
          textColor: const Color(0xFF94A3B8),
          borderColor: const Color(0x6664748B),
        );
    }
  }
}
