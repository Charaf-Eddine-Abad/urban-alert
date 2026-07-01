import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/features/notifications/data/models/notification_model.dart';
import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';

typedef OnNotificationCallback = void Function(AppNotification notification);

class StompService {
  StompClient? _client;
  bool _active = false;

  void connect({
    required String token,
    required OnNotificationCallback onNotification,
  }) {
    if (_active) return;
    _active = true;

    final wsUrl = ApiConstants.wsUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          _client?.subscribe(
            destination: '/user/queue/notifications',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;
              try {
                final json = jsonDecode(body) as Map<String, dynamic>;
                final notification = NotificationModel.fromJson(json).toDomain();
                onNotification(notification);
              } catch (e) {
                debugPrint('StompService: failed to parse notification — $e');
              }
            },
          );
        },
        onDisconnect: (_) {
          debugPrint('StompService: disconnected');
          _active = false;
        },
        onWebSocketError: (error) {
          debugPrint('StompService: WebSocket error — $error');
          _active = false;
        },
        onStompError: (frame) {
          debugPrint('StompService: STOMP error — ${frame.body}');
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );

    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    _active = false;
  }
}
