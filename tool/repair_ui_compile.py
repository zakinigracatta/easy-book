from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    source = file.read_text(encoding='utf-8')
    if old in source:
        source = source.replace(old, new, 1)
        file.write_text(source, encoding='utf-8')


replace_once(
    'lib/screens/business/promotion_management_screen.dart',
    'children: const [',
    'children: [',
)
replace_once(
    'lib/screens/business/quick_walk_in_booking_screen.dart',
    'children: const [',
    'children: [',
)
replace_once(
    'lib/screens/settings/help_screen.dart',
    'children: const [',
    'children: [',
)

print('Removed the final const contexts around localized/theme-aware widgets.')
