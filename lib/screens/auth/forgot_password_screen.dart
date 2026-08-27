import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/l10n.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    final rawEmail = _emailController.text.trim();
    if (rawEmail.isEmpty) {
      setState(() {
        _errorMessage = l10nOf(context).enterEmail;
      });
      return;
    }

    final normalizedEmail = rawEmail.toLowerCase();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(normalizedEmail)) {
      setState(() {
        _errorMessage = l10nOf(context).enterValidEmail;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .sendPasswordResetEmail(normalizedEmail);
      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.code == 'invalid-email') {
            _errorMessage = l10nOf(context).enterValidEmail;
          } else if (e.code == 'too-many-requests') {
            _errorMessage = l10nOf(context).tooManyRequests;
          } else if (e.code == 'network-request-failed') {
            _errorMessage = l10nOf(context).networkError;
          } else {
            _emailSent = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
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
              context.go('/login');
            }
          },
        ),
        title: Text(l10n.resetPassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.forgotPasswordTitle,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.resetPasswordInstructions,
                style: TextStyle(
                    color: AppColors.textMutedDark, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              if (_emailSent)
                GlassCard(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.success,
                        child: Icon(Icons.mark_email_read_rounded,
                            size: 34, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.resetLinkSent,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.resetLinkSentDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textMutedDark,
                            fontSize: 13,
                            height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: l10n.backToLogin,
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                )
              else
                GlassCard(
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: l10n.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                      color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      CustomButton(
                        text: l10n.sendResetLink,
                        isLoading: _isLoading,
                        onPressed: _handleSendResetLink,
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
