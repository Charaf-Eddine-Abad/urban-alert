import 'package:equatable/equatable.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';

sealed class MyAlertsState extends Equatable {
  const MyAlertsState();
  @override
  List<Object?> get props => [];
}

final class MyAlertsLoading extends MyAlertsState {
  const MyAlertsLoading();
}

final class MyAlertsLoaded extends MyAlertsState {
  const MyAlertsLoaded({
    required this.alerts,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Alert> alerts;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  MyAlertsLoaded copyWith({
    List<Alert>? alerts,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      MyAlertsLoaded(
        alerts: alerts ?? this.alerts,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [alerts, currentPage, hasMore, isLoadingMore];
}

final class MyAlertsError extends MyAlertsState {
  const MyAlertsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
