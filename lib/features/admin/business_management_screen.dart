import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';

class BusinessManagementScreen extends StatefulWidget {
  const BusinessManagementScreen({super.key});

  @override
  State<BusinessManagementScreen> createState() =>
      _BusinessManagementScreenState();
}

class _BusinessManagementScreenState extends State<BusinessManagementScreen> {
  String _searchQuery = '';
  bool? _verifiedFilter; // null = all, true = verified, false = unverified
  String? _mutatingId;

  @override
  Widget build(BuildContext context) {
    final businessesStream =
        FirebaseFirestore.instance.collection('businesses').snapshots();

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/admin/dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin/dashboard');
              }
            },
          ),
          title: const Text('إدارة الأنشطة التجارية',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim().toLowerCase()),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: 'بحث بالاسم أو التصنيف أو العنوان...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('الكل')),
                      ButtonSegment(value: true, label: Text('معتمد')),
                      ButtonSegment(value: false, label: Text('غير معتمد')),
                    ],
                    selected: {_verifiedFilter},
                    onSelectionChanged: (val) =>
                        setState(() => _verifiedFilter = val.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: businessesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 48, color: AppColors.error),
                            SizedBox(height: 12),
                            Text(
                              'تعذر تحميل الأنشطة التجارية. تحقق من الاتصال.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDocs = snapshot.data!.docs;

                  final filtered = allDocs.where((doc) {
                    final data = doc.data();
                    final isVerified = data['is_verified'] == true ||
                        data['isVerified'] == true;

                    if (_verifiedFilter != null &&
                        isVerified != _verifiedFilter) {
                      return false;
                    }

                    if (_searchQuery.isNotEmpty) {
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      final category =
                          (data['category'] ?? '').toString().toLowerCase();
                      final address =
                          (data['address'] ?? '').toString().toLowerCase();

                      return name.contains(_searchQuery) ||
                          category.contains(_searchQuery) ||
                          address.contains(_searchQuery);
                    }

                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront_outlined,
                                size: 56, color: AppColors.textMutedDark),
                            SizedBox(height: 12),
                            Text(
                              'لا توجد أنشطة تجارية مطابقة.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final id = doc.id;
                      final name = (data['name'] ?? 'نشاط تجاري').toString();
                      final category = (data['category'] ?? '').toString();
                      final address = (data['address'] ?? '').toString();
                      final isVerified = data['is_verified'] == true ||
                          data['isVerified'] == true;
                      final rating = (data['rating'] as num?)?.toDouble() ?? 5.0;

                      final isMutating = _mutatingId == id;
                      final detailsPath =
                          '/admin/businesses/${Uri.encodeComponent(id)}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          onTap: () => context.push(detailsPath),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.storefront_rounded,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              isVerified ? 'معتمد' : 'غير معتمد',
                                              style: TextStyle(
                                                color: isVerified
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            backgroundColor: (isVerified
                                                    ? AppColors.success
                                                    : AppColors.warning)
                                                .withValues(alpha: 0.15),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$category • $address',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '⭐ ${rating.toStringAsFixed(1)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => context.push(detailsPath),
                                      child: const Text('التفاصيل'),
                                    ),
                                    if (!isVerified) ...[
                                      const SizedBox(height: 6),
                                      FilledButton(
                                        onPressed: isMutating
                                            ? null
                                            : () => _verifyBusiness(doc.reference, id),
                                        child: isMutating
                                            ? const SizedBox.square(
                                                dimension: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text('اعتماد'),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyBusiness(
    DocumentReference<Map<String, dynamic>> reference,
    String id,
  ) async {
    setState(() => _mutatingId = id);
    try {
      await reference.update({
        'is_verified': true,
        'is_active': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم اعتماد النشاط بنجاح.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر اعتماد النشاط. تحقق من الاتصال.')),
        );
      }
    } finally {
      if (mounted) setState(() => _mutatingId = null);
    }
  }
}
