import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import 'admin_portal_shell.dart';

class AdminBusinessDetailsScreen extends StatefulWidget {
  const AdminBusinessDetailsScreen({required this.businessId, super.key});

  final String businessId;

  @override
  State<AdminBusinessDetailsScreen> createState() =>
      _AdminBusinessDetailsScreenState();
}

class _AdminBusinessDetailsScreenState
    extends State<AdminBusinessDetailsScreen> {
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(covariant AdminBusinessDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessId != widget.businessId) {
      _loadDetails();
    }
  }

  void _loadDetails() {
    final cleanId = widget.businessId.trim();
    if (cleanId.isEmpty) {
      _detailsFuture = Future.error(ArgumentError('Invalid business ID'));
    } else {
      _detailsFuture = _fetchBusinessDetails(cleanId);
    }
  }

  Future<Map<String, dynamic>> _fetchBusinessDetails(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('businesses')
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) {
      throw StateError('Business not found');
    }

    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;

    // Fetch owner information if available
    Map<String, dynamic>? ownerData;
    final ownerId = (data['owner_id'] ?? data['ownerId'] ?? '')
        .toString()
        .trim();
    if (ownerId.isNotEmpty) {
      try {
        final ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(ownerId)
            .get();
        if (ownerDoc.exists && ownerDoc.data() != null) {
          ownerData = Map<String, dynamic>.from(ownerDoc.data()!);
          ownerData['id'] = ownerDoc.id;
        }
      } catch (_) {}
    }

    // Fetch subcollections in parallel
    final servicesFuture = FirebaseFirestore.instance
        .collection('businesses')
        .doc(id)
        .collection('services')
        .get();
    final staffFuture = FirebaseFirestore.instance
        .collection('businesses')
        .doc(id)
        .collection('staff')
        .get();
    final reviewsFuture = FirebaseFirestore.instance
        .collection('businesses')
        .doc(id)
        .collection('reviews')
        .get();

    final results = await Future.wait([
      servicesFuture,
      staffFuture,
      reviewsFuture,
    ]);

    return {
      'business': data,
      'owner': ownerData,
      'services': results[0].docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(),
      'staff': results[1].docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'reviews': results[2].docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cleanId = widget.businessId.trim();

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/admin/businesses');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: adminText(
              context,
              'Back to businesses',
              'العودة إلى الأنشطة',
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin/businesses');
              }
            },
          ),
          title: Text(
            adminText(context, 'Business details', 'تفاصيل النشاط التجاري'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: cleanId.isEmpty
            ? _ErrorState(
                icon: Icons.error_outline_rounded,
                text: adminText(
                  context,
                  'Invalid business ID.',
                  'معرّف النشاط غير صالح.',
                ),
              )
            : FutureBuilder<Map<String, dynamic>>(
                future: _detailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    if (error is StateError) {
                      return _ErrorState(
                        icon: Icons.search_off_rounded,
                        text: adminText(
                          context,
                          'Business not found.',
                          'لم يتم العثور على هذا النشاط.',
                        ),
                        actionLabel: adminText(
                          context,
                          'Back to list',
                          'العودة للقائمة',
                        ),
                        onAction: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/admin/businesses');
                          }
                        },
                      );
                    }

                    return _ErrorState(
                      icon: Icons.cloud_off_rounded,
                      text: adminText(
                        context,
                        'Unable to load business details. Check your connection.',
                        'تعذر تحميل تفاصيل النشاط. تحقق من الاتصال.',
                      ),
                      actionLabel: adminText(
                        context,
                        'Try again',
                        'إعادة المحاولة',
                      ),
                      onAction: () => setState(() => _loadDetails()),
                    );
                  }

                  final data = snapshot.data!;
                  final business =
                      data['business'] as Map<String, dynamic>? ?? {};
                  final owner = data['owner'] as Map<String, dynamic>?;
                  final services = (data['services'] as List?) ?? [];
                  final staff = (data['staff'] as List?) ?? [];
                  final reviews = (data['reviews'] as List?) ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BusinessHeaderCard(business: business, owner: owner),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _InfoCard(
                              title: adminText(context, 'Owner', 'المالك'),
                              items: owner == null
                                  ? []
                                  : [
                                      {
                                        'title':
                                            (owner['full_name'] ??
                                                    owner['name'] ??
                                                    owner['email'] ??
                                                    adminText(
                                                      context,
                                                      'Business owner',
                                                      'مالك النشاط',
                                                    ))
                                                .toString(),
                                        'subtitle':
                                            '${owner['email'] ?? ''} • ${owner['phone'] ?? ''}',
                                      },
                                    ],
                            ),
                            _InfoCard(
                              title:
                                  '${adminText(context, 'Services', 'الخدمات')} (${services.length})',
                              items: services
                                  .take(6)
                                  .map(
                                    (s) => {
                                      'title':
                                          (s['name'] ??
                                                  s['service_name'] ??
                                                  adminText(
                                                    context,
                                                    'Service',
                                                    'خدمة',
                                                  ))
                                              .toString(),
                                      'subtitle':
                                          '${s['price'] ?? 0} ${adminText(context, 'AED', 'درهم')} • ${s['duration'] ?? s['duration_minutes'] ?? 30} ${adminText(context, 'min', 'دقيقة')}',
                                    },
                                  )
                                  .toList(),
                            ),
                            _InfoCard(
                              title:
                                  '${adminText(context, 'Employees', 'الموظفون')} (${staff.length})',
                              items: staff
                                  .take(6)
                                  .map(
                                    (st) => {
                                      'title':
                                          (st['name'] ??
                                                  st['full_name'] ??
                                                  adminText(
                                                    context,
                                                    'Employee',
                                                    'موظف',
                                                  ))
                                              .toString(),
                                      'subtitle':
                                          (st['role'] ??
                                                  st['specialty'] ??
                                                  adminText(
                                                    context,
                                                    'Specialist',
                                                    'أخصائي',
                                                  ))
                                              .toString(),
                                    },
                                  )
                                  .toList(),
                            ),
                            _InfoCard(
                              title:
                                  '${adminText(context, 'Reviews', 'التقييمات')} (${reviews.length})',
                              items: reviews
                                  .take(6)
                                  .map(
                                    (r) => {
                                      'title':
                                          '⭐ ${(r['rating'] ?? 5.0).toString()} - ${(r['user_name'] ?? r['userName'] ?? adminText(context, 'Customer', 'عميل')).toString()}',
                                      'subtitle':
                                          (r['comment'] ?? r['text'] ?? '')
                                              .toString(),
                                    },
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _BusinessHeaderCard extends StatelessWidget {
  const _BusinessHeaderCard({required this.business, this.owner});

  final Map<String, dynamic> business;
  final Map<String, dynamic>? owner;

  @override
  Widget build(BuildContext context) {
    final name = (business['name'] ?? 'نشاط تجاري').toString();
    final category = (business['category'] ?? '—').toString();
    final address = (business['address'] ?? '—').toString();
    final rating =
        (business['rating'] as num?)?.toDouble().toStringAsFixed(1) ?? '5.0';

    final isVerified =
        business['is_verified'] == true || business['isVerified'] == true;
    final isActive =
        business['is_active'] == true || business['isActive'] == true;

    final phone =
        (business['phone'] ??
                business['phone_number'] ??
                owner?['phone'] ??
                '—')
            .toString();
    final email =
        (business['email'] ??
                business['contact_email'] ??
                owner?['email'] ??
                '—')
            .toString();
    final website = (business['website'] ?? '—').toString();

    final rawDate = business['created_at'] ?? business['createdAt'];
    String createdDate = '—';
    if (rawDate != null) {
      if (rawDate is Timestamp) {
        createdDate = DateFormat.yMMMd().format(rawDate.toDate());
      } else if (rawDate is DateTime) {
        createdDate = DateFormat.yMMMd().format(rawDate);
      } else if (rawDate is String) {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) {
          createdDate = DateFormat.yMMMd().format(parsed);
        }
      }
    }

    final ownerName =
        (owner?['full_name'] ??
                owner?['name'] ??
                business['owner_id'] ??
                business['ownerId'] ??
                '—')
            .toString();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Chip(
                    avatar: Icon(
                      isVerified
                          ? Icons.verified_rounded
                          : Icons.pending_actions_rounded,
                      size: 16,
                      color: isVerified ? AppColors.success : AppColors.warning,
                    ),
                    label: Text(
                      isVerified
                          ? adminText(context, 'Approved', 'معتمد')
                          : adminText(context, 'Pending', 'غير معتمد'),
                      style: TextStyle(
                        color: isVerified
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor:
                        (isVerified ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(
                      isActive
                          ? Icons.check_circle_outline_rounded
                          : Icons.pause_circle_outline_rounded,
                      size: 16,
                      color: isActive ? AppColors.info : AppColors.error,
                    ),
                    label: Text(
                      isActive
                          ? adminText(context, 'Active', 'نشط')
                          : adminText(context, 'Inactive', 'غير نشط'),
                      style: TextStyle(
                        color: isActive ? AppColors.info : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor:
                        (isActive ? AppColors.info : AppColors.error)
                            .withValues(alpha: 0.15),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 28),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _DetailItem(
                label: adminText(context, 'Owner', 'المالك'),
                value: ownerName,
              ),
              _DetailItem(
                label: adminText(context, 'Category', 'التصنيف'),
                value: category,
              ),
              _DetailItem(
                label: adminText(context, 'Address', 'العنوان'),
                value: address,
              ),
              _DetailItem(
                label: adminText(context, 'Rating', 'التقييم'),
                value: '⭐ $rating',
              ),
              _DetailItem(
                label: adminText(context, 'Phone', 'الهاتف'),
                value: phone,
                isDirectional: true,
              ),
              _DetailItem(
                label: adminText(context, 'Email', 'البريد الإلكتروني'),
                value: email,
              ),
              _DetailItem(
                label: adminText(context, 'Website', 'الموقع الإلكتروني'),
                value: website,
              ),
              _DetailItem(
                label: adminText(context, 'Created', 'تاريخ الإنشاء'),
                value: createdDate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    this.isDirectional = false,
  });

  final String label;
  final String value;
  final bool isDirectional;

  @override
  Widget build(BuildContext context) {
    final textWidget = SelectableText(
      value,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          isDirectional
              ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: textWidget,
                )
              : textWidget,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.items});

  final String title;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 20),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  adminText(
                    context,
                    'No data available.',
                    'لا توجد بيانات متاحة.',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...items.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    (item['title'] ?? '').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      item['subtitle'] != null &&
                          item['subtitle']!.toString().isNotEmpty
                      ? Text(item['subtitle']!.toString())
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
