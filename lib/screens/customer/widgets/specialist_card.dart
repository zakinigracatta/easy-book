import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/staff_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../l10n/l10n.dart';

class SpecialistCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback? onTap;

  const SpecialistCard({
    super.key,
    required this.staff,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const fallbackAvatar =
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';
    final avatarUrl =
        staff.avatarUrl.isNotEmpty ? staff.avatarUrl : fallbackAvatar;

    return GlassCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // Avatar Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.cardDark),
                errorWidget: (context, url, err) => Image.network(
                  fallbackAvatar,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Specialist Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff.roleTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        staff.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                      if (staff.experienceYears > 0) ...[
                        const SizedBox(width: 10),
                        Text(
                          l10nOf(context)
                              .yearsExperience(staff.experienceYears),
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
          ],
        ),
      ),
    );
  }
}
