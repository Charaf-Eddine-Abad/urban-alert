import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_providers.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_state.dart';

class MyAlertsNotifier extends Notifier<MyAlertsState> {
  static const _pageSize = 10;

  @override
  MyAlertsState build() {
    Future.microtask(_loadInitial);
    return const MyAlertsLoading();
  }

  Future<void> _loadInitial() async {
    state = const MyAlertsLoading();
    try {
      final page = await ref
          .read(myAlertsRepositoryProvider)
          .getMyAlerts(page: 0, size: _pageSize);
      state = MyAlertsLoaded(
        alerts: page.content,
        currentPage: 0,
        hasMore: !page.last,
      );
    } on AppException catch (e) {
      state = MyAlertsError(e.message);
    }
  }

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    final current = state;
    if (current is! MyAlertsLoaded || current.isLoadingMore || !current.hasMore) return;

    state = current.copyWith(isLoadingMore: true);
    try {
      final nextPage = current.currentPage + 1;
      final page = await ref
          .read(myAlertsRepositoryProvider)
          .getMyAlerts(page: nextPage, size: _pageSize);
      state = current.copyWith(
        alerts: [...current.alerts, ...page.content],
        currentPage: nextPage,
        hasMore: !page.last,
        isLoadingMore: false,
      );
    } on AppException {
      final current0 = state;
      if (current0 is MyAlertsLoaded) {
        state = current0.copyWith(isLoadingMore: false);
      }
    }
  }

  /// Creates an alert and optionally uploads [images] to Cloudinary.
  /// Throws [AppException] on failure — callers handle display.
  Future<Alert> createAlert({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    required int categoryId,
    required String priority,
    required bool isAnonymous,
    List<XFile> images = const [],
  }) async {
    final repo = ref.read(myAlertsRepositoryProvider);
    final alert = await repo.createAlert(
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      categoryId: categoryId,
      priority: priority,
      isAnonymous: isAnonymous,
    );

    if (images.isNotEmpty) {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      for (final image in images) {
        final url = await cloudinary.uploadImage(image);
        await repo.addImage(alert.id, url);
      }
    }

    await _loadInitial();
    return alert;
  }

  /// Updates an existing alert and uploads any new [newImages].
  Future<void> updateAlert(
    int id, {
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    int? categoryId,
    String? priority,
    bool? isAnonymous,
    List<XFile> newImages = const [],
  }) async {
    final repo = ref.read(myAlertsRepositoryProvider);
    await repo.updateAlert(
      id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      categoryId: categoryId,
      priority: priority,
      isAnonymous: isAnonymous,
    );

    if (newImages.isNotEmpty) {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      for (final image in newImages) {
        final url = await cloudinary.uploadImage(image);
        await repo.addImage(id, url);
      }
    }

    await _loadInitial();
  }

  /// Optimistically removes from list then calls the API.
  Future<void> deleteAlert(int id) async {
    final current = state;
    if (current is MyAlertsLoaded) {
      state = current.copyWith(
        alerts: current.alerts.where((a) => a.id != id).toList(),
      );
    }
    try {
      await ref.read(myAlertsRepositoryProvider).deleteAlert(id);
    } on AppException {
      // Restore list on failure and re-throw so the UI can show the error.
      await _loadInitial();
      rethrow;
    }
  }
}
