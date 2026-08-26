from pathlib import Path

path = Path('lib/widgets/business/owner_booking_card.dart')
source = path.read_text(encoding='utf-8')
old = """      case BookingStatus.arrived:\n        return Row(\n          children: [\n            Expanded(\n              child: _actionButton(\n                label: 'Start Service',\n                icon: Icons.play_circle_fill_rounded,\n                color: AppColors.accent,\n                onPressed: () =>\n                    onStatusChanged?.call(BookingStatus.inProgress),\n              ),\n            ),\n            const SizedBox(width: 8),\n            Expanded(\n              child: _actionButton(\n                label: 'Complete',\n                icon: Icons.task_alt_rounded,\n                color: AppColors.success,\n                onPressed: () => onStatusChanged?.call(BookingStatus.completed),\n              ),\n            ),\n          ],\n        );\n"""
new = """      case BookingStatus.arrived:\n        // Server transition rules require arrived -> inProgress -> completed.\n        // Do not offer a direct Complete action that the backend will reject.\n        return Row(\n          children: [\n            Expanded(\n              child: _actionButton(\n                label: 'Start Service',\n                icon: Icons.play_circle_fill_rounded,\n                color: AppColors.accent,\n                onPressed: () =>\n                    onStatusChanged?.call(BookingStatus.inProgress),\n              ),\n            ),\n          ],\n        );\n"""
if old not in source:
    raise SystemExit('Expected arrived action block not found.')
path.write_text(source.replace(old, new, 1), encoding='utf-8')
print('Aligned arrived -> inProgress -> completed UI with backend rules.')
