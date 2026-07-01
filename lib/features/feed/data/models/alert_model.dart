import 'package:urban_alert/features/feed/data/models/problem_type_model.dart';
import 'package:urban_alert/features/feed/data/models/user_summary_model.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';

class AlertModel {
  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    required this.priority,
    required this.isAnonymous,
    required this.images,
    required this.videos,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.category,
    this.ticketId,
  });

  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final String priority;
  final bool isAnonymous;
  final List<String> images;
  final List<String> videos;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserSummaryModel? user;
  final ProblemTypeModel? category;
  final int? ticketId;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'NEW',
      priority: json['priority'] as String? ?? 'LOW',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      user: json['user'] != null
          ? UserSummaryModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? ProblemTypeModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      ticketId: json['ticketId'] as int?,
    );
  }

  Alert toDomain() => Alert(
        id: id,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        status: AlertStatus.fromString(status),
        priority: AlertPriority.fromString(priority),
        isAnonymous: isAnonymous,
        images: images,
        videos: videos,
        createdAt: createdAt,
        user: user?.toDomain(),
        category: category?.toDomain(),
        ticketId: ticketId,
      );

  /// Handles both ISO-8601 strings and Spring's LocalDateTime array format.
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
