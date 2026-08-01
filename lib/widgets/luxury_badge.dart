import 'package:flutter/material.dart';

class LuxuryBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const LuxuryBadge({
    super.key,
    required this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? const Color(0xFF6C3EF4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
