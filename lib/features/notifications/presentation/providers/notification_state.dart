import 'package:equatable/equatable.dart';
import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.notifications,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<AppNotification> notifications;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      NotificationLoaded(
        notifications: notifications ?? this.notifications,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props =>
      [notifications, currentPage, hasMore, isLoadingMore];
}

final class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
