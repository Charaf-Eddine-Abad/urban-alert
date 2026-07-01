import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get formattedDate => DateFormat('dd/MM/yyyy', 'fr_FR').format(this);

  String get formattedDateTime =>
      DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(this);

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return formattedDate;
  }
}

extension NullableDateTimeFormatting on DateTime? {
  String get formattedDateOrDash => this?.formattedDate ?? '—';
  String get timeAgoOrDash => this?.timeAgo ?? '—';
}

extension IsoStringParsing on String {
  DateTime toDateTime() => DateTime.parse(this).toLocal();
}
