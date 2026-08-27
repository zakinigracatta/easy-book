import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_model.dart';
import '../../l10n/l10n.dart';
import '../../providers/app_providers.dart';
import '../../services/navigation_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10nOf(context).invalidCredentials),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
            requestedRole: _selectedRole,
          );

      if (mounted) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await firebaseUser.reload();
          if (!mounted) return;
          final refreshedUser = FirebaseAuth.instance.currentUser;
          if (refreshedUser != null && !refreshedUser.emailVerified) {
            context.go('/verify-email');
            return;
          }
        }

        final pendingRoute = NavigationService().consumePendingRoute();
        if (user.role == UserRole.owner ||
            user.role == UserRole.businessOwner) {
          NavigationService().clearPendingRoute();
          context.go('/owner-dashboard');
        } else if (pendingRoute != null && pendingRoute.isNotEmpty) {
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go(pendingRoute);
          }
        } else {
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/home');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('An error occurred during sign in: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
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
        title: Text(l10n.signIn),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.welcomeBack,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.signInSubtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Role Toggle Segment
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.customer),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.customer
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _selectedRole == UserRole.customer
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline),
                        ),
                        child: Center(
                          child: Text(
                            l10n.customer,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedRole == UserRole.customer
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.owner),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.owner
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _selectedRole == UserRole.owner
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline),
                        ),
                        child: Center(
                          child: Text(
                            l10n.businessOwner,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedRole == UserRole.owner
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: l10n.emailOrPhone,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          l10n.forgotPassword,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: l10n.signIn,
                      isLoading: _isLoading,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.registerAsCustomer} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(l10n.customerRegister),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.registerAsPartner} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/business-register'),
                        child: Text(
                          l10n.ownerRegister,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
