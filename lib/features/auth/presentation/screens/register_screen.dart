import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:urban_alert/core/router/route_names.dart';
import 'package:urban_alert/core/theme/app_text_styles.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_providers.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_state.dart';
import 'package:urban_alert/features/auth/presentation/widgets/auth_header.dart';
import 'package:urban_alert/shared/widgets/app_button.dart';
import 'package:urban_alert/shared/widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _prenomCtr = TextEditingController();
  final _nomCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _villeCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final _confirmCtr = TextEditingController();

  DateTime? _dateNaissance;
  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _prenomCtr.dispose();
    _nomCtr.dispose();
    _emailCtr.dispose();
    _phoneCtr.dispose();
    _villeCtr.dispose();
    _passwordCtr.dispose();
    _confirmCtr.dispose();
    super.dispose();
  }

  // Navigate to verify-phone when registration succeeds
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(authNotifierProvider, (prev, next) {
        if (next is AuthRegistered) {
          context.goNamed(
            RouteNames.verifyPhoneName,
            extra: next.normalizedPhone,
          );
        }
      });
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 16), // must be at least 16 years old
      helpText: 'Date de naissance',
      locale: const Locale('fr'),
    );
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateNaissance == null) {
      // Shown via validator but double-check
      return;
    }
    await ref.read(authNotifierProvider.notifier).register(
          email: _emailCtr.text.trim(),
          rawPhone: _phoneCtr.text.trim(),
          nom: _nomCtr.text.trim(),
          prenom: _prenomCtr.text.trim(),
          dateNaissance: DateFormat('yyyy-MM-dd').format(_dateNaissance!),
          ville: _villeCtr.text.trim(),
          password: _passwordCtr.text,
        );
  }

  void _resetError() {
    final s = ref.read(authNotifierProvider);
    if (s is AuthFailure) ref.read(authNotifierProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final errorMsg = authState is AuthFailure ? authState.message : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const AuthHeader(
                  title: 'Créer un compte',
                  subtitle: 'Rejoignez UrbanAlert et contribuez\nà l\'amélioration de votre ville.',
                ),

                const SizedBox(height: 32),

                // ── Prénom / Nom ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _prenomCtr,
                        label: 'Prénom',
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        onChanged: (_) => _resetError(),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _nomCtr,
                        label: 'Nom',
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _resetError(),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Email ─────────────────────────────────────────────────────
                AppTextField(
                  controller: _emailCtr,
                  label: 'Email',
                  hint: 'vous@exemple.ma',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) => _resetError(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email requis';
                    if (!RegExp(r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(v.trim())) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ── Phone ─────────────────────────────────────────────────────
                AppTextField(
                  controller: _phoneCtr,
                  label: 'Téléphone',
                  hint: '0612345678',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onChanged: (_) => _resetError(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Téléphone requis';
                    final c = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                    if (!RegExp(r'^(?:\+212|0)[67]\d{8}$').hasMatch(c)) {
                      return 'Numéro marocain invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ── Date de naissance ─────────────────────────────────────────
                _DatePickerField(
                  value: _dateNaissance,
                  onTap: _pickDate,
                ),

                const SizedBox(height: 14),

                // ── Ville ─────────────────────────────────────────────────────
                AppTextField(
                  controller: _villeCtr,
                  label: 'Ville',
                  hint: 'Casablanca',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  onChanged: (_) => _resetError(),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ville requise' : null,
                ),

                const SizedBox(height: 14),

                // ── Password ──────────────────────────────────────────────────
                AppTextField(
                  controller: _passwordCtr,
                  label: 'Mot de passe',
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  autofillHints: const [AutofillHints.newPassword],
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  onChanged: (_) => _resetError(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (v.length < 6) return 'Au moins 6 caractères';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ── Confirm password ──────────────────────────────────────────
                AppTextField(
                  controller: _confirmCtr,
                  label: 'Confirmer le mot de passe',
                  obscureText: !_showConfirm,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirmation requise';
                    if (v != _passwordCtr.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                // ── Error banner ──────────────────────────────────────────────
                if (errorMsg != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: errorMsg),
                ],

                const SizedBox(height: 28),

                AppButton(
                  label: 'Créer mon compte',
                  loading: isLoading,
                  onPressed: _submit,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed(RouteNames.loginName),
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.value, required this.onTap});
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = value != null
        ? DateFormat('dd/MM/yyyy').format(value!)
        : 'Date de naissance';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.cake_outlined),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: value != null
                ? scheme.onSurface
                : scheme.onSurfaceVariant.withValues(alpha: 0.7),
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
