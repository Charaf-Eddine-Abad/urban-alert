import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_alert/core/router/route_names.dart';
import 'package:urban_alert/core/theme/app_text_styles.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_providers.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_state.dart';
import 'package:urban_alert/features/auth/presentation/widgets/auth_header.dart';
import 'package:urban_alert/shared/widgets/app_button.dart';
import 'package:urban_alert/shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _phoneCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .login(_phoneCtr.text.trim(), _passwordCtr.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final errorMsg = authState is AuthFailure ? authState.message : null;

    // Listen once — clear error when user starts typing again
    ref.listen(authNotifierProvider, (prev, next) {
      if (next is AuthFailure) {
        // Error shown inline; no snackbar needed
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                const AuthHeader(
                  title: 'Bon retour 👋',
                  subtitle: 'Connectez-vous pour signaler et suivre\nvos problèmes urbains.',
                ),

                const SizedBox(height: 40),

                // ── Phone ───────────────────────────────────────────────────
                AppTextField(
                  controller: _phoneCtr,
                  label: 'Téléphone',
                  hint: '0612345678',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onChanged: (_) {
                    if (authState is AuthFailure) {
                      ref.read(authNotifierProvider.notifier).reset();
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Numéro de téléphone requis';
                    }
                    final cleaned = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                    if (!RegExp(r'^(?:\+212|0)[67]\d{8}$').hasMatch(cleaned)) {
                      return 'Numéro marocain invalide (ex: 0612345678)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────────────────────
                AppTextField(
                  controller: _passwordCtr,
                  label: 'Mot de passe',
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  autofillHints: const [AutofillHints.password],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  onChanged: (_) {
                    if (authState is AuthFailure) {
                      ref.read(authNotifierProvider.notifier).reset();
                    }
                  },
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    return null;
                  },
                ),

                // ── Error banner ─────────────────────────────────────────────
                if (errorMsg != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: errorMsg),
                ],

                const SizedBox(height: 28),

                // ── Submit ───────────────────────────────────────────────────
                AppButton(
                  label: 'Se connecter',
                  loading: isLoading,
                  onPressed: _submit,
                ),

                const SizedBox(height: 24),

                // ── Register link ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed(RouteNames.registerName),
                      child: const Text('S\'inscrire'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
