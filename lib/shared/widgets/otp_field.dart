import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urban_alert/core/theme/app_colors.dart';
import 'package:urban_alert/core/theme/app_text_styles.dart';

/// 6-box OTP input. Moves focus automatically between boxes and
/// calls [onCompleted] when all 6 digits are filled.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  final void Function(String otp) onCompleted;
  final void Function(String partial)? onChanged;
  final bool enabled;

  @override
  State<OtpField> createState() => OtpFieldState();
}

class OtpFieldState extends State<OtpField> {
  static const int _length = 6;

  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _nodes =
      List.generate(_length, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _nodes.first.requestFocus();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste: distribute digits across boxes
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextIndex = (digits.length < _length ? digits.length : _length - 1);
      _nodes[nextIndex].requestFocus();
    } else if (value.isNotEmpty) {
      if (index < _length - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    }

    final current = _otp;
    widget.onChanged?.call(current);
    if (current.length == _length && !current.contains(' ')) {
      widget.onCompleted(current);
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.symmetric(
            horizontal: i == 2 ? 12 : 4, // gap between digit groups
          ),
          child: _OtpBox(
            controller: _controllers[i],
            focusNode: _nodes[i],
            enabled: widget.enabled,
            scheme: scheme,
            onChanged: (v) => _onChanged(v, i),
            onBackspace: () => _onBackspace(i),
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.scheme,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ColorScheme scheme;
  final void Function(String) onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          onBackspace();
        }
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: AppTextStyles.titleLarge.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: focusNode.hasFocus
              ? scheme.primaryContainer.withValues(alpha: 0.3)
              : AppColors.surfaceVariantLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
