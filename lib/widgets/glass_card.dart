import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart' as legacy;

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final bg = backgroundColor ??
        (isDark ? legacy.AppColors.glassBgDark : colors.surface);
    final border = borderColor ??
        (isDark
            ? legacy.AppColors.glassBorderDark
            : colors.outline.withValues(alpha: 0.55));

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? legacy.AppColors.shadowDark
                : const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: isDark ? 10 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(14.0),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
