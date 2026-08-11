import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/staff_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class SpecialistOptionCard extends StatelessWidget {
  final StaffModel? staff;
  final bool isAnySpecialist;
  final bool isSelected;
  final VoidCallback onTap;

  const SpecialistOptionCard({
    super.key,
    this.staff,
    this.isAnySpecialist = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnySpecialist) {
      return GlassCard(
        onTap: onTap,
        borderColor: isSelected ? AppColors.primary : null,
        backgroundColor:
            isSelected ? AppColors.primary.withValues(alpha: 0.15) : null,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.people_alt_rounded,
                  color: AppColors.accent, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Any Available Specialist',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Maximum slot options across all eligible staff',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ),
            _radioIndicator(isSelected),
          ],
        ),
      );
    }

    final s = staff!;
    const fallbackAvatar =
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';
    final avatarUrl = s.avatarUrl.isNotEmpty ? s.avatarUrl : fallbackAvatar;

    return GlassCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      backgroundColor:
          isSelected ? AppColors.primary.withValues(alpha: 0.15) : null,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorWidget: (context, url, err) => Image.network(fallbackAvatar,
                  width: 56, height: 56, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.roleTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${s.rating.toStringAsFixed(1)} (${s.reviewCount})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    if (s.experienceYears > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•  ${s.experienceYears} yrs exp',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _radioIndicator(isSelected),
        ],
      ),
    );
  }

  Widget _radioIndicator(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textMutedDark,
          width: 2,
        ),
        color: selected ? AppColors.primary : Colors.transparent,
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }
}
