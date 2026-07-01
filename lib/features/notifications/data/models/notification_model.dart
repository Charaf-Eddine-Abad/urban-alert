import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.relatedAlertId,
    this.relatedProblemId,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final int? relatedAlertId;
  final int? relatedProblemId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'GENERAL',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      relatedAlertId: json['relatedAlertId'] as int?,
      relatedProblemId: json['relatedProblemId'] as int?,
    );
  }

  AppNotification toDomain() => AppNotification(
        id: id,
        type: NotificationType.fromString(type),
        title: title,
        body: body,
        isRead: isRead,
        createdAt: createdAt,
        relatedAlertId: relatedAlertId,
        relatedProblemId: relatedProblemId,
      );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is List && value.isNotEmpty) {
      final v = value.map((e) => (e as num).toInt()).toList();
      return DateTime(
        v[0],
        v.length > 1 ? v[1] : 1,
        v.length > 2 ? v[2] : 1,
        v.length > 3 ? v[3] : 0,
        v.length > 4 ? v[4] : 0,
        v.length > 5 ? v[5] : 0,
      );
    }
    return null;
  }
}
