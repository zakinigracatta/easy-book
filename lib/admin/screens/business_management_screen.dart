import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';

class BusinessManagementScreen extends ConsumerStatefulWidget {
  const BusinessManagementScreen({super.key});

  @override
  ConsumerState<BusinessManagementScreen> createState() =>
      _BusinessManagementScreenState();
}

class _BusinessManagementScreenState
    extends ConsumerState<BusinessManagementScreen> {
  String query = '';
  bool? verified;
  String? mutatingId;

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(adminBusinessesProvider(verified));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(
          width: 340,
          child: TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'بحث بالاسم أو التصنيف أو العنوان',
            ),
          ),
        ),
        SegmentedButton<bool?>(
          segments: const [
            ButtonSegment(value: null, label: Text('الكل')),
            ButtonSegment(value: true, label: Text('معتمد')),
            ButtonSegment(value: false, label: Text('غير معتمد')),
          ],
          selected: {verified},
          onSelectionChanged: (value) => setState(() => verified = value.first),
        ),
        IconButton.outlined(
          tooltip: 'تحديث',
          onPressed: () => ref.invalidate(adminBusinessesProvider(verified)),
          icon: const Icon(Icons.refresh),
        ),
      ]),
      const SizedBox(height: 18),
      businesses.when(
        loading: () => const SizedBox(
          height: 280,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => _Message(
          icon: Icons.cloud_off_outlined,
          text: 'تعذر تحميل الأنشطة. تحقق من الاتصال وصلاحيات Firestore.',
          action: () => ref.invalidate(adminBusinessesProvider(verified)),
        ),
        data: (items) {
          final needle = query.toLowerCase();
          final filtered = items.where((item) {
            if (needle.isEmpty) return true;
            return item
                    .text(['name', 'category', 'address'], fallback: '')
                    .toLowerCase()
                    .contains(needle) ||
                item
                    .text(['name'], fallback: '')
                    .toLowerCase()
                    .contains(needle) ||
                item
                    .text(['category'], fallback: '')
                    .toLowerCase()
                    .contains(needle) ||
                item
                    .text(['address'], fallback: '')
                    .toLowerCase()
                    .contains(needle);
          }).toList(growable: false);
          if (filtered.isEmpty) {
            return const _Message(
              icon: Icons.storefront_outlined,
              text: 'لا توجد أنشطة مطابقة.',
            );
          }
          return Card(
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('النشاط')),
                  DataColumn(label: Text('التصنيف')),
                  DataColumn(label: Text('العنوان')),
                  DataColumn(label: Text('التقييم')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('الإجراءات')),
                ],
                rows: filtered.map((business) {
                  final isVerified = business.data['is_verified'] == true;
                  final loading = mutatingId == business.id;
                  final detailsPath =
                      '/admin/businesses/${Uri.encodeComponent(business.id)}';
                  return DataRow(
                    onSelectChanged: (_) => context.go(detailsPath),
                    cells: [
                      DataCell(Text(business.text(['name']))),
                      DataCell(Text(business.text(['category']))),
                      DataCell(Text(business.text(['address']))),
                      DataCell(
                          Text(business.number(['rating']).toStringAsFixed(1))),
                      DataCell(Chip(
                        avatar: Icon(
                          isVerified ? Icons.verified : Icons.pending_outlined,
                          size: 17,
                        ),
                        label: Text(isVerified ? 'معتمد' : 'غير معتمد'),
                      )),
                      DataCell(Row(children: [
                        TextButton(
                          onPressed: () => context.go(detailsPath),
                          child: const Text('التفاصيل'),
                        ),
                        if (!isVerified)
                          FilledButton.tonal(
                            onPressed: loading ? null : () => _verify(business),
                            child: loading
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('اعتماد'),
                          ),
                      ])),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      Text('يتم تحميل أول 50 سجلًا فقط لحماية الأداء.',
          style: Theme.of(context).textTheme.bodySmall),
    ]);
  }

  Future<void> _verify(AdminRecord business) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اعتماد النشاط؟'),
        content: Text(
          'سيتم اعتماد ${business.text(['name'])} وإتاحته وفق قواعد المنصة.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('اعتماد')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => mutatingId = business.id);
    try {
      final user = ref.read(authProvider)!;
      await ref.read(adminRepositoryProvider).setBusinessVerified(
            actorRole: user.role,
            businessId: business.id,
            verified: true,
          );
      ref.invalidate(adminBusinessesProvider(verified));
      ref.invalidate(adminDashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم اعتماد النشاط بنجاح.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تعذر اعتماد النشاط. تحقق من الصلاحيات والاتصال.')),
        );
      }
    } finally {
      if (mounted) setState(() => mutatingId = null);
    }
  }
}

class AdminBusinessDetailsScreen extends ConsumerWidget {
  const AdminBusinessDetailsScreen({required this.businessId, super.key});
  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (businessId.trim().isEmpty) {
      return const _Message(
        icon: Icons.error_outline,
        text: 'معرّف النشاط غير صالح.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IconButton(
            tooltip: 'العودة إلى الأنشطة',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin/businesses');
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Text('تفاصيل النشاط',
              style: Theme.of(context).textTheme.headlineSmall),
        ]),
        const SizedBox(height: 16),
        ref.watch(adminBusinessDetailsProvider(businessId)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, __) => _Message(
                icon: Icons.error_outline,
                text: error is StateError
                    ? 'لم يتم العثور على هذا النشاط.'
                    : 'تعذر تحميل تفاصيل النشاط.',
                action: () =>
                    ref.invalidate(adminBusinessDetailsProvider(businessId)),
              ),
              data: (details) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BusinessHeader(record: details.business),
                  const SizedBox(height: 16),
                  Wrap(spacing: 16, runSpacing: 16, children: [
                    _SectionCard(
                      title: 'المالك',
                      records:
                          details.owner == null ? const [] : [details.owner!],
                    ),
                    _SectionCard(title: 'الخدمات', records: details.services),
                    _SectionCard(title: 'الموظفون', records: details.staff),
                    _SectionCard(title: 'الحجوزات', records: details.bookings),
                    _SectionCard(title: 'التقييمات', records: details.reviews),
                  ]),
                ],
              ),
            ),
      ],
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  const _BusinessHeader({required this.record});
  final AdminRecord record;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(spacing: 24, runSpacing: 16, children: [
            _Field('الاسم', record.text(['name'])),
            _Field('التصنيف', record.text(['category'])),
            _Field('العنوان', record.text(['address'])),
            _Field('التقييم', record.number(['rating']).toStringAsFixed(1)),
            _Field(
              'حالة الاعتماد',
              record.data['is_verified'] is bool
                  ? record.data['is_verified'] == true
                      ? 'معتمد'
                      : 'غير معتمد'
                  : record.text(['approval_status', 'status']),
            ),
            _Field(
              'الحالة النشطة',
              record.data['is_active'] is bool
                  ? record.data['is_active'] == true
                      ? 'نشط'
                      : 'غير نشط'
                  : record.data['isActive'] is bool
                      ? record.data['isActive'] == true
                          ? 'نشط'
                          : 'غير نشط'
                      : '—',
            ),
            _Field('الهاتف', record.text(['phone', 'phone_number'])),
            _Field(
                'البريد الإلكتروني', record.text(['email', 'contact_email'])),
            _Field(
              'تاريخ الإنشاء',
              record.date(['created_at', 'createdAt']) == null
                  ? '—'
                  : DateFormat.yMMMd().format(
                      record.date(['created_at', 'createdAt'])!,
                    ),
            ),
          ]),
        ),
      );
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          SelectableText(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.records});
  final String title;
  final List<AdminRecord> records;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 420,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$title (${records.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider(height: 24),
              if (records.isEmpty)
                const Text('لا توجد بيانات متاحة.')
              else
                for (final record in records.take(6))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(record.text(
                        ['name', 'full_name', 'service_name', 'user_name'])),
                    subtitle: Text(record.text(
                        ['role', 'role_title', 'status', 'comment'],
                        fallback: record.id)),
                  ),
            ]),
          ),
        ),
      );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 280,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: action, child: const Text('إعادة المحاولة')),
            ],
          ]),
        ),
      );
}
