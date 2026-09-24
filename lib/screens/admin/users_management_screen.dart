import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_localization.dart';
import '../../widgets/glass_card.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  static const _pageSize = 50;

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  QueryDocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _error = null;
      _docs.clear();
      _cursor = null;
    });
    await _loadPage(initial: true);
  }

  Future<void> _loadMore() => _loadPage(initial: false);

  Future<void> _loadPage({required bool initial}) async {
    if (!initial && (_isLoadingMore || !_hasMore)) return;
    if (!initial) setState(() => _isLoadingMore = true);

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('users')
          .orderBy(FieldPath.documentId)
          .limit(_pageSize);
      if (!initial && _cursor != null) {
        query = query.startAfterDocument(_cursor!);
      }

      final snapshot = await query.get();
      if (!mounted) return;

      setState(() {
        _docs.addAll(snapshot.docs);
        _cursor = snapshot.docs.isEmpty ? _cursor : snapshot.docs.last;
        _hasMore = snapshot.docs.length == _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop()
              ? context.pop()
              : context.go('/admin/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/admin/dashboard'),
          ),
          title: Text(
            adminText(context, 'Users & accounts', 'المستخدمون والحسابات'),
          ),
          actions: [
            IconButton(
              tooltip: adminText(context, 'Refresh', 'تحديث'),
              onPressed: _isLoading ? null : _loadInitial,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _docs.isEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        message: adminText(
          context,
          'Unable to load user accounts.',
          'تعذر تحميل حسابات المستخدمين.',
        ),
        action: TextButton.icon(
          onPressed: _loadInitial,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(adminText(context, 'Try again', 'إعادة المحاولة')),
        ),
      );
    }
    if (_docs.isEmpty) {
      return _MessageState(
        icon: Icons.people_outline_rounded,
        message: adminText(
          context,
          'No user accounts found.',
          'لا توجد حسابات مستخدمين.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _docs.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _docs.length) {
            return Center(
              child: OutlinedButton.icon(
                onPressed: _isLoadingMore ? null : _loadMore,
                icon: _isLoadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more_rounded),
                label: Text(
                  adminText(context, 'Load more', 'تحميل المزيد'),
                ),
              ),
            );
          }

          final data = _docs[index].data();
          final name = (data['full_name'] ??
                  data['name'] ??
                  data['business_name'] ??
                  data['email'] ??
                  adminText(context, 'User', 'مستخدم'))
              .toString();
          final email = (data['email'] ?? '').toString();
          final phone = (data['phone'] ?? '').toString();
          final role = (data['role'] ?? 'customer').toString();

          return GlassCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(_roleIcon(role))),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (email.isNotEmpty) Text(email),
                  if (phone.isNotEmpty)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(phone),
                    ),
                ],
              ),
              trailing: Chip(label: Text(_roleLabel(context, role))),
            ),
          );
        },
      ),
    );
  }

  static IconData _roleIcon(String role) {
    return switch (role) {
      'admin' || 'super_admin' => Icons.admin_panel_settings_rounded,
      'owner' || 'business_owner' || 'businessOwner' =>
        Icons.storefront_rounded,
      _ => Icons.person_rounded,
    };
  }

  static String _roleLabel(BuildContext context, String role) {
    return switch (role) {
      'super_admin' => adminText(context, 'Super admin', 'مسؤول أعلى'),
      'admin' => adminText(context, 'Admin', 'مسؤول'),
      'owner' || 'business_owner' || 'businessOwner' =>
        adminText(context, 'Business owner', 'مالك نشاط'),
      _ => adminText(context, 'Customer', 'عميل'),
    };
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: 12),
                action!,
              ],
            ],
          ),
        ),
      );
}
