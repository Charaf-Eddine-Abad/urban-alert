/// Utilities for Moroccan phone number handling.
abstract final class PhoneUtils {
  /// Normalizes a Moroccan phone to the +212 international format.
  /// Accepts: 0612345678 or +212612345678 (with optional spaces/dashes).
  static String normalize(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.startsWith('0')) {
      return '+212${cleaned.substring(1)}';
    }
    return cleaned;
  }

  /// Returns a partially-masked phone for display: +212 6•• ••• 678
  static String mask(String normalized) {
    if (normalized.length < 6) return normalized;
    final visible = normalized.substring(normalized.length - 3);
    return '${normalized.substring(0, 5)} •• ••• $visible';
  }

  /// Regex that accepts both Moroccan formats.
  static final RegExp moroccanPattern =
      RegExp(r'^(?:\+212|0)[67]\d{8}$');

  static bool isValid(String phone) =>
      moroccanPattern.hasMatch(phone.replaceAll(RegExp(r'[\s\-]'), ''));
}
