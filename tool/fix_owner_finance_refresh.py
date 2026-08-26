from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    source = file.read_text(encoding='utf-8')
    if old not in source:
        raise SystemExit(f'Expected block not found in {path}')
    source = source.replace(old, new, 1)
    file.write_text(source, encoding='utf-8')
    print(f'updated {path}')


bookings = Path('lib/screens/business/owner_bookings_screen.dart')
source = bookings.read_text(encoding='utf-8')
if "../../providers/owner_finance_providers.dart" not in source:
    source = source.replace(
        "import '../../providers/owner_providers.dart';\n",
        "import '../../providers/owner_providers.dart';\nimport '../../providers/owner_finance_providers.dart';\n",
        1,
    )
bookings.write_text(source, encoding='utf-8')

replace_once(
    'lib/screens/business/owner_bookings_screen.dart',
    """                        onStatusChanged: (newStatus) {\n                          ref\n                              .read(ownerBookingsProvider.notifier)\n                              .updateStatus(booking.id, newStatus);\n                          ScaffoldMessenger.of(context).showSnackBar(\n                            SnackBar(\n                              content: Text(\n                                  context.tr('Updated booking status to {status}', params: {'status': newStatus.name.toUpperCase()})),\n                              backgroundColor: AppColors.primary,\n                            ),\n                          );\n                        },\n""",
    """                        onStatusChanged: (newStatus) async {\n                          try {\n                            await ref\n                                .read(ownerBookingsProvider.notifier)\n                                .updateStatus(booking.id, newStatus);\n                            ref.invalidate(ownerTodayProfitAndLossProvider);\n                            ref.invalidate(ownerProfitAndLossProvider);\n                            if (!context.mounted) return;\n                            ScaffoldMessenger.of(context).showSnackBar(\n                              SnackBar(\n                                content: Text(\n                                  context.tr(\n                                    'Updated booking status to {status}',\n                                    params: {\n                                      'status': newStatus.name.toUpperCase(),\n                                    },\n                                  ),\n                                ),\n                                backgroundColor: AppColors.primary,\n                              ),\n                            );\n                          } catch (_) {\n                            if (!context.mounted) return;\n                            ScaffoldMessenger.of(context).showSnackBar(\n                              SnackBar(\n                                content: Text(context.tr('Something went wrong')),\n                                backgroundColor: AppColors.error,\n                              ),\n                            );\n                          }\n                        },\n""",
)

replace_once(
    'lib/screens/business/owner_dashboard_screen.dart',
    """              onStatusChanged: (newStatus) {\n                ref\n                    .read(ownerBookingsProvider.notifier)\n                    .updateStatus(booking.id, newStatus);\n                ref.invalidate(ownerTodayProfitAndLossProvider);\n                ScaffoldMessenger.of(context).showSnackBar(\n                  SnackBar(\n                    content: Text(\n                      context.tr(\n                        'Booking status updated to {status}',\n                        params: {'status': newStatus.name.toUpperCase()},\n                      ),\n                    ),\n                  ),\n                );\n              },\n""",
    """              onStatusChanged: (newStatus) async {\n                try {\n                  await ref\n                      .read(ownerBookingsProvider.notifier)\n                      .updateStatus(booking.id, newStatus);\n                  ref.invalidate(ownerTodayProfitAndLossProvider);\n                  ref.invalidate(ownerProfitAndLossProvider);\n                  if (!context.mounted) return;\n                  ScaffoldMessenger.of(context).showSnackBar(\n                    SnackBar(\n                      content: Text(\n                        context.tr(\n                          'Booking status updated to {status}',\n                          params: {'status': newStatus.name.toUpperCase()},\n                        ),\n                      ),\n                    ),\n                  );\n                } catch (_) {\n                  if (!context.mounted) return;\n                  ScaffoldMessenger.of(context).showSnackBar(\n                    SnackBar(\n                      content: Text(context.tr('Something went wrong')),\n                      backgroundColor: AppColors.error,\n                    ),\n                  );\n                }\n              },\n""",
)

print('Owner finance refresh race fixed.')
