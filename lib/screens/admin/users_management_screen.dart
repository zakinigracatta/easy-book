import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_localization.dart';
import '../../widgets/glass_card.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersQuery = FirebaseFirestore.instance.collection('users');

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
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: usersQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _MessageState(
                icon: Icons.cloud_off_rounded,
                message: adminText(
                  context,
                  'Unable to load user accounts.',
                  'تعذر تحميل حسابات المستخدمين.',
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs.toList()
              ..sort((a, b) {
                final aData = a.data();
                final bData = b.data();
                final aName = (aData['full_name'] ??
                        aData['name'] ??
                        aData['email'] ??
                        '')
                    .toString()
                    .toLowerCase();
                final bName = (bData['full_name'] ??
                        bData['name'] ??
                        bData['email'] ??
                        '')
                    .toString()
                    .toLowerCase();
                return aName.compareTo(bName);
              });

            if (docs.isEmpty) {
              return _MessageState(
                icon: Icons.people_outline_rounded,
                message: adminText(
                  context,
                  'No user accounts found.',
                  'لا توجد حسابات مستخدمين.',
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = docs[index].data();
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
                    leading: CircleAvatar(
                      child: Icon(_roleIcon(role)),
                    ),
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
                    trailing: Chip(
                      label: Text(_roleLabel(context, role)),
                    ),
                  ),
                );
              },
            );
          },
        ),
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
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

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
            ],
          ),
        ),
      );
}
