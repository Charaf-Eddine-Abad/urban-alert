import 'package:equatable/equatable.dart';
import 'package:urban_alert/features/suivi/domain/entities/problem.dart';

sealed class SuiviState extends Equatable {
  const SuiviState();
  @override
  List<Object?> get props => [];
}

final class SuiviLoading extends SuiviState {
  const SuiviLoading();
}

final class SuiviLoaded extends SuiviState {
  const SuiviLoaded({
    required this.problems,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Problem> problems;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  SuiviLoaded copyWith({
    List<Problem>? problems,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      SuiviLoaded(
        problems: problems ?? this.problems,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [problems, currentPage, hasMore, isLoadingMore];
}

final class SuiviError extends SuiviState {
  const SuiviError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
