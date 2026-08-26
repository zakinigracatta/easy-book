import 'package:flutter/material.dart';
import '../../../models/business_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import 'working_hours_section.dart';
import '../../../l10n/app_localizations.dart';

class AboutSection extends StatelessWidget {
  final BusinessModel business;

  AboutSection({
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
              Text(context.tr('About Business'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                business.description.isNotEmpty
                    ? business.description
                    : 'Welcome to ${business.name}. We provide premium quality grooming and wellness services.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Amenities & Facilities
        if (business.amenities.isNotEmpty) ...[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('Amenities & Features'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData,
                              size: 16, color: AppColors.primaryLight),
                          SizedBox(width: 6),
                          Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          SizedBox(height: 16),
        ],

        // Contact & Location Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Contact & Location'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 14),
              _contactRow(
                  Icons.location_on_outlined, 'Address', business.address),
              if (business.phone != null && business.phone!.isNotEmpty) ...[
                SizedBox(height: 12),
                _contactRow(Icons.phone_outlined, 'Phone', business.phone!),
              ],
              if (business.website != null && business.website!.isNotEmpty) ...[
                SizedBox(height: 12),
                _contactRow(
                    Icons.language_outlined, 'Website', business.website!),
              ],
            ],
          ),
        ),

        SizedBox(height: 16),

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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryLight),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
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
