import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/role_routing.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_failure.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({
    super.key,
    this.verificationEmailWasSent = false,
  });

  final bool verificationEmailWasSent;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isLoading = false;
  static const _initialCooldown = Duration(seconds: 60);
  Timer? _cooldownTimer;
  int _remainingSeconds = 0;
  bool _emailWasSent = false;

  @override
  void initState() {
    super.initState();
    _emailWasSent = widget.verificationEmailWasSent;
    if (_emailWasSent) _startCooldown(_initialCooldown);
  }

  void _startCooldown(Duration duration) {
    _cooldownTimer?.cancel();
    setState(() => _remainingSeconds = duration.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).sendEmailVerification();
      _emailWasSent = true;
      _startCooldown(_initialCooldown);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال رسالة التحقق.')),
        );
      }
    } catch (error) {
      final failure = AuthFailure.from(error);
      final isRateLimited = failure.code == 'too-many-requests';
      if (isRateLimited) {
        _startCooldown(const Duration(minutes: 5));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRateLimited
                  ? 'طلبات كثيرة جدًا. يرجى الانتظار بضع دقائق ثم المحاولة مجددًا.'
                  : failure.message,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      final verified =
          await ref.read(authProvider.notifier).isCurrentEmailVerified();
      if (!mounted) return;
      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'لم يتم التحقق من البريد بعد. يرجى مراجعة صندوق الوارد.')),
        );
        return;
      }
      final user = ref.read(authProvider);
      context.go(user == null ? '/login' : RoleRouting.homeFor(user));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _useAnotherAccount() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authProvider)?.email ?? 'عنوان بريدك الإلكتروني';
    return Scaffold(
      appBar: AppBar(title: const Text('تحقق من بريدك الإلكتروني')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_read_outlined,
                      size: 64, color: AppColors.primary),
                  const SizedBox(height: 20),
                  const Text('راجع صندوق الوارد',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    _emailWasSent
                        ? 'أرسلنا رابط تحقق إلى $email. افتحه ثم عد إلى هنا.'
                        : 'لم تُرسل رسالة تحقق بعد. استخدم الزر أدناه لإرسالها إلى $email.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMutedDark),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'تحققت من بريدي الإلكتروني',
                    isLoading: _isLoading,
                    onPressed: _checkVerification,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading || _remainingSeconds > 0
                        ? null
                        : _resendEmail,
                    child: Text(
                      _remainingSeconds > 0
                          ? 'إعادة الإرسال متاحة خلال $_remainingSeconds ثانية'
                          : 'إعادة إرسال رسالة التحقق',
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _isLoading ? null : _useAnotherAccount,
                    child: const Text('استخدام حساب آخر'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
