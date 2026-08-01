import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/welcome');
            }
          },
        ),
        title: const Text('Business Portal Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront_rounded, size: 70, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text('Salon Partner Sign In', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Manage appointments, staff schedules & sales', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(controller: _emailController, label: 'Salon Email', prefixIcon: Icons.email_outlined),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _passwordController, label: 'Password', obscureText: true, prefixIcon: Icons.lock_outline),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Open Partner Dashboard',
                      backgroundColor: AppColors.accent,
                      onPressed: () => context.go('/owner-dashboard'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
