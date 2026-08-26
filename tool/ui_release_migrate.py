from __future__ import annotations

import os
import re
from pathlib import Path

ROOTS = [Path('lib/screens'), Path('lib/widgets')]
L10N = Path('lib/l10n/app_localizations.dart')

THEME_REPLACEMENTS = {
    'AppColors.bgDark': 'Theme.of(context).scaffoldBackgroundColor',
    'AppColors.backgroundDark': 'Theme.of(context).scaffoldBackgroundColor',
    'AppColors.cardDark': 'Theme.of(context).colorScheme.surface',
    'AppColors.surfaceDark': 'Theme.of(context).colorScheme.surface',
    'AppColors.glassBgDark': 'Theme.of(context).colorScheme.surface.withValues(alpha: 0.35)',
    'AppColors.glassBorderDark': 'Theme.of(context).dividerColor',
    'AppColors.textPrimaryDark': 'Theme.of(context).colorScheme.onSurface',
    'AppColors.textSecondaryDark': 'Theme.of(context).colorScheme.onSurfaceVariant',
    'AppColors.textMutedDark': 'Theme.of(context).colorScheme.onSurfaceVariant',
}

# Conservative: only plain visible literals without interpolation. Dynamic strings
# are handled manually after the source audit reports them.
TEXT_LITERAL_RE = re.compile(
    r'''\bText\(\s*([\"'])(?P<text>(?:(?!\1).)*)\1''',
    re.DOTALL,
)
CONST_CONSTRUCTOR_RE = re.compile(r'\bconst\s+(?=[A-Z][A-Za-z0-9_\.]*\s*\()')
ALPHA_RE = re.compile(r'[A-Za-z]')

# Data/technical labels that do not need language translation.
PLAIN_TEXT_ALLOWLIST = {
    'EN', 'AR', 'RU',
}


def relative_l10n_import(path: Path) -> str:
    rel = os.path.relpath(L10N, path.parent).replace(os.sep, '/')
    return f"import '{rel}';"


def ensure_l10n_import(source: str, path: Path) -> str:
    if 'app_localizations.dart' in source:
        return source
    import_line = relative_l10n_import(path)
    lines = source.splitlines()
    insert_at = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            insert_at = i + 1
    lines.insert(insert_at, import_line)
    return '\n'.join(lines) + ('\n' if source.endswith('\n') else '')


def migrate_file(path: Path) -> bool:
    source = path.read_text(encoding='utf-8')
    original = source

    # Any constructor made theme-aware can no longer live inside a const widget
    # subtree. Removing const from constructor invocations is semantically safe
    # and leaves constant declarations/default values untouched.
    if any(token in source for token in THEME_REPLACEMENTS):
        source = CONST_CONSTRUCTOR_RE.sub('', source)
        for old, new in THEME_REPLACEMENTS.items():
            source = source.replace(old, new)

    localized = False

    def localize_text(match: re.Match[str]) -> str:
        nonlocal localized
        full = match.group(0)
        text = match.group('text')
        if '$' in text or not ALPHA_RE.search(text) or text in PLAIN_TEXT_ALLOWLIST:
            return full
        # Already translated Text(context.tr(...)) is not matched by this regex.
        quote = match.group(1)
        localized = True
        return f'Text(context.tr({quote}{text}{quote})'

    source = TEXT_LITERAL_RE.sub(localize_text, source)
    if localized:
        source = ensure_l10n_import(source, path)
        source = CONST_CONSTRUCTOR_RE.sub('', source)

    if source != original:
        path.write_text(source, encoding='utf-8')
        return True
    return False


def main() -> None:
    changed: list[str] = []
    for root in ROOTS:
        for path in sorted(root.rglob('*.dart')):
            if migrate_file(path):
                changed.append(str(path))

    print(f'UI migration changed {len(changed)} files.')
    for path in changed:
        print(path)


if __name__ == '__main__':
    main()
