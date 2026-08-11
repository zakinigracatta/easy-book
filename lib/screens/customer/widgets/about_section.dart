import 'package:flutter/material.dart';
import '../../../models/business_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import 'working_hours_section.dart';

class AboutSection extends StatelessWidget {
  final BusinessModel business;

  const AboutSection({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Business',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                business.description.isNotEmpty
                    ? business.description
                    : 'Welcome to ${business.name}. We provide premium quality grooming and wellness services.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Amenities & Facilities
        if (business.amenities.isNotEmpty) ...[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amenities & Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: business.amenities.map((amenity) {
                    IconData iconData;
                    if (amenity.toLowerCase().contains('wifi') ||
                        amenity.toLowerCase().contains('wi-fi')) {
                      iconData = Icons.wifi_rounded;
                    } else if (amenity.toLowerCase().contains('park')) {
                      iconData = Icons.local_parking_rounded;
                    } else if (amenity.toLowerCase().contains('card') ||
                        amenity.toLowerCase().contains('pay')) {
                      iconData = Icons.credit_card_rounded;
                    } else if (amenity.toLowerCase().contains('wheel') ||
                        amenity.toLowerCase().contains('access')) {
                      iconData = Icons.accessible_rounded;
                    } else {
                      iconData = Icons.check_circle_outline_rounded;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorderDark),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData,
                              size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          Text(
                            amenity,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Contact & Location Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact & Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              _contactRow(
                  Icons.location_on_outlined, 'Address', business.address),
              if (business.phone != null && business.phone!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _contactRow(Icons.phone_outlined, 'Phone', business.phone!),
              ],
              if (business.website != null && business.website!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _contactRow(
                    Icons.language_outlined, 'Website', business.website!),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Weekly Working Hours
        WorkingHoursSection(workingHours: business.workingHours),
      ],
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMutedDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
