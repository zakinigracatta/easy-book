from pathlib import Path


def edit(path: str, replacements: list[tuple[str, str]]) -> None:
    file = Path(path)
    source = file.read_text(encoding='utf-8')
    original = source
    for old, new in replacements:
        source = source.replace(old, new)
    if source != original:
        file.write_text(source, encoding='utf-8')
        print(f'updated {path}')


edit('lib/screens/business/add_service_screen.dart', [
    ("'$mins minutes'", '"$mins ${context.tr(\'minutes\')}"'),
    ("Text('Failed to save service: $e')",
     "Text(context.tr('Unable to save service. Please try again.'))"),
    ("content: Text(widget.initialService != null\n                ? 'Service updated successfully!'\n                : 'New service created!'),",
     "content: Text(context.tr(\n              widget.initialService != null\n                  ? 'Service updated successfully!'\n                  : 'New service created!',\n            )),"),
])

edit('lib/screens/business/booking_calendar_screen.dart', [
    ('"Bookings for ${DateFormat(', '"${context.tr(\'Bookings for\')} ${DateFormat('),
])

edit('lib/screens/business/business_working_hours_screen.dart', [
    ("Text('Unable to load working hours: $error')",
     "Text(context.tr('Unable to load working hours. Please try again.'))"),
    ("Text('Failed to update working hours: $e')",
     "Text(context.tr('Unable to update working hours. Please try again.'))"),
])

edit('lib/screens/business/customer_management_screen.dart', [
    ('"${c.phone} • ${c.completedVisits} visits"',
     '"${c.phone} • ${context.tr(\'{count} visits\', params: {\'count\': c.completedVisits})}"'),
    ('"${c.noShowCount} No-Shows"',
     '"${context.tr(\'{count} No-Shows\', params: {\'count\': c.noShowCount})}"'),
])

edit('lib/screens/business/employee_management_screen.dart', [
    ('"${st.rating} (${st.reviewCount} reviews)"',
     '"${st.rating} (${context.tr(\'{count} reviews\', params: {\'count\': st.reviewCount})})"'),
    ('"${st.experienceYears} yrs exp"',
     'context.tr(\'{count} yrs exp\', params: {\'count\': st.experienceYears})'),
])

edit('lib/screens/business/owner_bookings_screen.dart', [
    ("Text('Updated booking status to ${newStatus.name.toUpperCase()}')",
     "Text(context.tr(\n                        'Updated booking status to {status}',\n                        params: {'status': newStatus.name.toUpperCase()},\n                      ))"),
])

edit('lib/screens/business/owner_gallery_screen.dart', [
    ("Text('${urls.length} photo(s) uploaded successfully.')",
     "Text(context.tr(\n                  '{count} photos uploaded successfully.',\n                  params: {'count': urls.length},\n                ))"),
    ("Text('Photo upload failed: $e')",
     "Text(context.tr('Photo upload failed. Please try again.'))"),
    ("Text('Could not delete photo: $e')",
     "Text(context.tr('Could not delete photo. Please try again.'))"),
])

edit('lib/screens/business/owner_reviews_screen.dart', [
    ("Text('$total reviews')",
     "Text(context.tr('{count} reviews', params: {'count': total}))"),
    ("Text('$replied of $total reviews replied to')",
     "Text(context.tr(\n                      '{replied} of {total} reviews replied to',\n                      params: {'replied': replied, 'total': total},\n                    ))"),
    ("Text('Reply to ${review.userName}')",
     "Text(context.tr('Reply to {name}', params: {'name': review.userName}))"),
    ("Text('Failed to save reply: $e')",
     "Text(context.tr('Failed to save reply. Please try again.'))"),
])

edit('lib/screens/business/promotion_management_screen.dart', [
    ("Text('Valid: $startStr – $endStr')",
     "Text(context.tr(\n                            'Valid: {start} – {end}',\n                            params: {'start': startStr, 'end': endStr},\n                          ))"),
])

edit('lib/screens/business/quick_walk_in_booking_screen.dart', [
    ("Text('Failed to create walk-in: $e')",
     "Text(context.tr('Failed to create walk-in. Please try again.'))"),
])

edit('lib/screens/customer/widgets/business_hero.dart', [
    ("Text('Sharing ${business.name}...')",
     "Text(context.tr('Sharing {business}...', params: {'business': business.name}))"),
])

edit('lib/screens/customer/widgets/reviews_section.dart', [
    ("Text('$totalReviews reviews')",
     "Text(context.tr('{count} reviews', params: {'count': totalReviews}))"),
])

edit('lib/screens/customer/widgets/specialist_card.dart', [
    ('"•  ${staff.experienceYears} yrs experience"',
     '"•  ${context.tr(\'{count} yrs experience\', params: {\'count\': staff.experienceYears})}"'),
])

edit('lib/screens/customer/widgets/specialist_option_card.dart', [
    ('"•  ${s.experienceYears} yrs exp"',
     '"•  ${context.tr(\'{count} yrs exp\', params: {\'count\': s.experienceYears})}"'),
])

edit('lib/widgets/business/owner_booking_card.dart', [
    ("Text('Staff: ${booking.staffName}')",
     "Text(context.tr('Staff: {name}', params: {'name': booking.staffName}))"),
])

# Booking progress labels are dynamic values passed to Text, so migrate them
# explicitly and make the current label readable in both light and dark themes.
progress = Path('lib/screens/customer/widgets/booking_progress_header.dart')
source = progress.read_text(encoding='utf-8')
if 'app_localizations.dart' not in source:
    source = source.replace(
        "import 'package:flutter/material.dart';\n",
        "import 'package:flutter/material.dart';\nimport '../../../l10n/app_localizations.dart';\n",
    )
source = source.replace(
    "final steps = ['Specialist', 'Date & Time', 'Summary'];",
    "final steps = [\n      context.tr('Specialist'),\n      context.tr('Date & Time'),\n      context.tr('Summary'),\n    ];",
)
source = source.replace(
    "color: isCurrent\n                          ? Colors.white\n                          : (isDone",
    "color: isCurrent\n                          ? AppColors.primary\n                          : (isDone",
)
progress.write_text(source, encoding='utf-8')
print('updated lib/screens/customer/widgets/booking_progress_header.dart')

print('Final active UI localization repair applied.')
