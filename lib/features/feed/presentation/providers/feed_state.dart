import 'package:equatable/equatable.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';

sealed class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

final class FeedLoading extends FeedState {
  const FeedLoading();
}

final class FeedLoaded extends FeedState {
  const FeedLoaded({
    required this.alerts,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.searchQuery = '',
  });

  final List<Alert> alerts;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;

  FeedLoaded copyWith({
    List<Alert>? alerts,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
  }) =>
      FeedLoaded(
        alerts: alerts ?? this.alerts,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props =>
      [alerts, currentPage, hasMore, isLoadingMore, searchQuery];
}

final class FeedError extends FeedState {
  const FeedError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
