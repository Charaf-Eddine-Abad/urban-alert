import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_alert/core/router/route_names.dart';
import 'package:urban_alert/core/theme/app_colors.dart';
import 'package:urban_alert/core/theme/app_text_styles.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_providers.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_state.dart';
import 'package:urban_alert/shared/utils/phone_utils.dart';
import 'package:urban_alert/shared/widgets/app_button.dart';
import 'package:urban_alert/shared/widgets/otp_field.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  const VerifyPhoneScreen({super.key, required this.normalizedPhone});

  /// The +212... phone passed from the register screen.
  final String normalizedPhone;

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final _otpKey = GlobalKey<OtpFieldState>();

  late Timer _timer;
  int _remaining = 60;
  bool get _canResend => _remaining == 0;

  String _partialCode = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _remaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining == 0) {
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (code.length != 6) return;
    await ref
        .read(authNotifierProvider.notifier)
        .verifyPhone(widget.normalizedPhone, code);
  }

  void _resend() {
    // TODO: call resend-otp endpoint once it is implemented in the backend
    _otpKey.currentState?.clear();
    ref.read(authNotifierProvider.notifier).reset();
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nouveau code envoyé sur WhatsApp')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final errorMsg = authState is AuthFailure ? authState.message : null;

    // Clear OTP boxes on error
    ref.listen(authNotifierProvider, (prev, next) {
      if (next is AuthFailure) {
        _otpKey.currentState?.clear();
        setState(() => _partialCode = '');
      }
    });

    final maskedPhone = PhoneUtils.mask(widget.normalizedPhone);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.goNamed(RouteNames.registerName),
        ),
        title: const Text('Vérification'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ── Icon ──────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_chat_read_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                'Code de vérification',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Un code à 6 chiffres a été envoyé\nvia WhatsApp au ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: maskedPhone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // ── OTP boxes ─────────────────────────────────────────────────
              OtpField(
                key: _otpKey,
                enabled: !isLoading,
                onChanged: (partial) =>
                    setState(() => _partialCode = partial),
                onCompleted: _verify,
              ),

              // ── Error ─────────────────────────────────────────────────────
              if (errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMsg,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Verify button (manual submit if OTP paste doesn't trigger) ─
              AppButton(
                label: 'Vérifier',
                loading: isLoading,
                enabled: _partialCode.length == 6,
                onPressed: () => _verify(_partialCode),
              ),

              const SizedBox(height: 28),

              // ── Resend ────────────────────────────────────────────────────
              Center(
                child: _canResend
                    ? TextButton.icon(
                        onPressed: _resend,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Renvoyer le code'),
                      )
                    : Text(
                        'Renvoyer le code dans $_remaining s',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
