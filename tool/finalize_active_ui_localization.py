from pathlib import Path


def edit(path: str, replacements: list[tuple[str, str]]) -> None:
    file = Path(path)
    source = file.read_text(encoding='utf-8')
    original = source
    for old, new in replacements:
        if old in source:
            source = source.replace(old, new)
    if source != original:
        file.write_text(source, encoding='utf-8')
        print(f'updated {path}')


def add_map_entries(path: str, entries: str) -> None:
    file = Path(path)
    source = file.read_text(encoding='utf-8')
    marker = entries.splitlines()[0].strip()
    if marker in source:
        return
    source = source.rsplit('};', 1)[0].rstrip() + '\n\n' + entries.rstrip() + '\n};\n'
    file.write_text(source, encoding='utf-8')
    print(f'updated {path}')


# Remaining direct visible text from ui_release_audit_test.
edit('lib/screens/business/booking_calendar_screen.dart', [
    (
        "'Bookings for ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}'",
        "context.tr('Bookings for {date}', params: {'date': DateFormat('EEE, MMM d, yyyy').format(_selectedDate)})",
    ),
])

edit('lib/screens/business/customer_management_screen.dart', [
    (
        "'${c.phone} • ${c.completedVisits} visits'",
        "context.tr('{phone} • {count} visits', params: {'phone': c.phone, 'count': c.completedVisits})",
    ),
    (
        "'${c.noShowCount} No-Shows'",
        "context.tr('{count} No-Shows', params: {'count': c.noShowCount})",
    ),
])

edit('lib/screens/business/employee_management_screen.dart', [
    (
        "'${st.rating} (${st.reviewCount} reviews)'",
        "context.tr('{rating} ({count} reviews)', params: {'rating': st.rating, 'count': st.reviewCount})",
    ),
    (
        "'${st.experienceYears} yrs exp'",
        "context.tr('{count} yrs exp', params: {'count': st.experienceYears})",
    ),
])

edit('lib/screens/business/owner_bookings_screen.dart', [
    (
        "'Updated booking status to ${newStatus.name.toUpperCase()}'",
        "context.tr('Updated booking status to {status}', params: {'status': newStatus.name.toUpperCase()})",
    ),
])

edit('lib/screens/business/owner_reviews_screen.dart', [
    (
        "'$total reviews'",
        "context.tr('{count} reviews', params: {'count': total})",
    ),
    (
        "'$replied of $total reviews replied to'",
        "context.tr('{replied} of {total} reviews replied to', params: {'replied': replied, 'total': total})",
    ),
])

edit('lib/screens/business/promotion_management_screen.dart', [
    (
        "'Valid: $startStr – $endStr'",
        "context.tr('Valid: {start} – {end}', params: {'start': startStr, 'end': endStr})",
    ),
])

edit('lib/screens/customer/widgets/reviews_section.dart', [
    (
        "'$totalReviews reviews'",
        "context.tr('{count} reviews', params: {'count': totalReviews})",
    ),
])

edit('lib/screens/customer/widgets/specialist_card.dart', [
    (
        "'•  ${staff.experienceYears} yrs experience'",
        "context.tr('• {count} yrs experience', params: {'count': staff.experienceYears})",
    ),
])

edit('lib/screens/customer/widgets/specialist_option_card.dart', [
    (
        "'•  ${s.experienceYears} yrs exp'",
        "context.tr('• {count} yrs exp', params: {'count': s.experienceYears})",
    ),
])

edit('lib/widgets/business/owner_booking_card.dart', [
    (
        "'Staff: ${booking.staffName}'",
        "context.tr('Staff: {name}', params: {'name': booking.staffName})",
    ),
])

# The audit parses context.tr keys from source text, while the translation maps are
# runtime Dart strings. Normalize escaped newlines before comparing the two.
edit('test/ui_release_audit_test.dart', [
    (
        "final key = match.group(2)!;",
        "final key = match.group(2)!.replaceAll(r'\\n', '\\n');",
    ),
])

# New dynamic templates introduced above.
add_map_entries(
    'lib/l10n/arabic_runtime_translations.dart',
    """  'Bookings for {date}': 'حجوزات يوم {date}',
  '{phone} • {count} visits': '{phone} • {count} زيارة',
  '{rating} ({count} reviews)': '{rating} ({count} مراجعة)',
  '• {count} yrs experience': '• {count} سنة خبرة',
  '• {count} yrs exp': '• {count} سنة خبرة',""",
)

add_map_entries(
    'lib/l10n/russian_runtime_translations.dart',
    """  'Bookings for {date}': 'Записи на {date}',
  '{phone} • {count} visits': '{phone} • визитов: {count}',
  '{rating} ({count} reviews)': '{rating} (отзывов: {count})',
  '• {count} yrs experience': '• опыт: {count} лет',
  '• {count} yrs exp': '• опыт: {count} лет',""",
)

print('Remaining UI localization test failures repaired.')
