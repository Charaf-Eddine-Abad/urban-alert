import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unread notification count shown as a badge on the nav bar.
/// Incremented by the STOMP WebSocket service (Phase 8) and reset when the
/// user opens the Notifications tab.
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);
