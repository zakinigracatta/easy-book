from pathlib import Path


def replace(path: str, old: str, new: str) -> None:
    file = Path(path)
    source = file.read_text(encoding='utf-8')
    if old not in source:
        raise RuntimeError(f'Expected pattern not found in {path}: {old[:80]!r}')
    file.write_text(source.replace(old, new), encoding='utf-8')


# Owner reviews: theme-aware helpers need the caller BuildContext.
replace(
    'lib/screens/business/owner_reviews_screen.dart',
    '''          _buildOverviewCard(\n            average: average,''',
    '''          _buildOverviewCard(\n            context: context,\n            average: average,''',
)
replace(
    'lib/screens/business/owner_reviews_screen.dart',
    '''  Widget _buildOverviewCard({\n    required double average,''',
    '''  Widget _buildOverviewCard({\n    required BuildContext context,\n    required double average,''',
)
replace(
    'lib/screens/business/owner_reviews_screen.dart',
    '''                      _ratingBar(\n                        star,''',
    '''                      _ratingBar(\n                        context,\n                        star,''',
)
replace(
    'lib/screens/business/owner_reviews_screen.dart',
    '  Widget _ratingBar(int star, double value) {',
    '  Widget _ratingBar(BuildContext context, int star, double value) {',
)

# Chat bubble helper.
replace(
    'lib/screens/customer/chat_screen.dart',
    '  Widget _msgBubble(String text, {required bool isMe}) {',
    '  Widget _msgBubble(BuildContext context, String text, {required bool isMe}) {',
)
chat = Path('lib/screens/customer/chat_screen.dart')
s = chat.read_text(encoding='utf-8')
s = s.replace('_msgBubble(', '_msgBubble(context, ')
s = s.replace('_msgBubble(context, BuildContext context, ', '_msgBubble(BuildContext context, ')
chat.write_text(s, encoding='utf-8')

# About contact helper.
replace(
    'lib/screens/customer/widgets/about_section.dart',
    '  Widget _contactRow(IconData icon, String label, String value) {',
    '  Widget _contactRow(BuildContext context, IconData icon, String label, String value) {',
)
about = Path('lib/screens/customer/widgets/about_section.dart')
s = about.read_text(encoding='utf-8')
s = s.replace('_contactRow(', '_contactRow(context, ')
s = s.replace('_contactRow(context, BuildContext context, ', '_contactRow(BuildContext context, ')
about.write_text(s, encoding='utf-8')

# Business hero image placeholder.
replace(
    'lib/screens/customer/widgets/business_hero.dart',
    '  Widget _coverPlaceholder() {',
    '  Widget _coverPlaceholder(BuildContext context) {',
)
hero = Path('lib/screens/customer/widgets/business_hero.dart')
s = hero.read_text(encoding='utf-8')
s = s.replace('_coverPlaceholder()', '_coverPlaceholder(context)')
hero.write_text(s, encoding='utf-8')

# Reviews rating bars.
replace(
    'lib/screens/customer/widgets/reviews_section.dart',
    '  Widget _barRow(String label, double pct) {',
    '  Widget _barRow(BuildContext context, String label, double pct) {',
)
reviews = Path('lib/screens/customer/widgets/reviews_section.dart')
s = reviews.read_text(encoding='utf-8')
for stars in range(1, 6):
    s = s.replace(f"_barRow('{stars} ★',", f"_barRow(context, '{stars} ★',")
reviews.write_text(s, encoding='utf-8')

# Specialist selection radio helper.
replace(
    'lib/screens/customer/widgets/specialist_option_card.dart',
    '  Widget _radioIndicator(bool selected) {',
    '  Widget _radioIndicator(BuildContext context, bool selected) {',
)
specialist = Path('lib/screens/customer/widgets/specialist_option_card.dart')
s = specialist.read_text(encoding='utf-8')
s = s.replace('_radioIndicator(isSelected)', '_radioIndicator(context, isSelected)')
specialist.write_text(s, encoding='utf-8')

# Owner booking overflow button helper.
replace(
    'lib/widgets/business/owner_booking_card.dart',
    '''  Widget _iconActionButton(\n      {required IconData icon, required VoidCallback onPressed}) {''',
    '''  Widget _iconActionButton(\n    BuildContext context, {\n    required IconData icon,\n    required VoidCallback onPressed,\n  }) {''',
)
owner_card = Path('lib/widgets/business/owner_booking_card.dart')
s = owner_card.read_text(encoding='utf-8')
s = s.replace('_iconActionButton(\n              icon:', '_iconActionButton(\n              context,\n              icon:')
owner_card.write_text(s, encoding='utf-8')

print('Applied targeted BuildContext compile repairs.')
