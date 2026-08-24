import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum IngestionPermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unavailable,
}

class IngestionPlatformStatus {
  final bool isAndroid;
  final bool smsAvailable;
  final IngestionPermissionState smsPermission;
  final bool notificationAccess;

  const IngestionPlatformStatus({
    required this.isAndroid,
    required this.smsAvailable,
    required this.smsPermission,
    required this.notificationAccess,
  });

  const IngestionPlatformStatus.unavailable()
    : isAndroid = false,
      smsAvailable = false,
      smsPermission = IngestionPermissionState.unavailable,
      notificationAccess = false;

  factory IngestionPlatformStatus.fromMap(Map<Object?, Object?> map) {
    final raw = map['smsStatus'] as String?;
    final state = IngestionPermissionState.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => IngestionPermissionState.unavailable,
    );
    return IngestionPlatformStatus(
      isAndroid: map['platform'] == 'android',
      smsAvailable: map['smsAvailable'] == true,
      smsPermission: state,
      notificationAccess: map['notificationAccess'] == true,
    );
  }
}

class NativeIngestionEvent {
  final String eventId;
  final String type;
  final Map<String, Object?> payload;

  const NativeIngestionEvent({
    required this.eventId,
    required this.type,
    required this.payload,
  });

  factory NativeIngestionEvent.fromMap(Map<Object?, Object?> source) {
    return NativeIngestionEvent(
      eventId: source['eventId'] as String? ?? '',
      type: source['type'] as String? ?? '',
      payload: source.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}

abstract class IngestionPlatform {
  Stream<void> get eventsAvailable;
  Future<IngestionPlatformStatus> getStatus();
  Future<IngestionPlatformStatus> requestSmsPermission();
  Future<void> openAppSettings();
  Future<void> openNotificationAccessSettings();
  Future<void> configure({
    required bool smsEnabled,
    required bool notificationEnabled,
    required List<String> smsSenders,
    required List<String> notificationPackages,
  });
  Future<List<NativeIngestionEvent>> pendingEvents();
  Future<void> acknowledgeEvents(List<String> eventIds);
}

class MethodChannelIngestionPlatform implements IngestionPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.financeflow.app/ingestion',
  );
  final StreamController<void> _events = StreamController<void>.broadcast();

  MethodChannelIngestionPlatform() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'eventsAvailable') _events.add(null);
    });
  }

  @override
  Stream<void> get eventsAvailable => _events.stream;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<IngestionPlatformStatus> getStatus() async {
    if (!_isAndroid) return const IngestionPlatformStatus.unavailable();
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getStatus',
    );
    return IngestionPlatformStatus.fromMap(result ?? const {});
  }

  @override
  Future<IngestionPlatformStatus> requestSmsPermission() async {
    if (!_isAndroid) return const IngestionPlatformStatus.unavailable();
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'requestSmsPermission',
    );
    return IngestionPlatformStatus.fromMap(result ?? const {});
  }

  @override
  Future<void> openAppSettings() async {
    if (_isAndroid) await _channel.invokeMethod<void>('openAppSettings');
  }

  @override
  Future<void> openNotificationAccessSettings() async {
    if (_isAndroid) {
      await _channel.invokeMethod<void>('openNotificationAccessSettings');
    }
  }

  @override
  Future<void> configure({
    required bool smsEnabled,
    required bool notificationEnabled,
    required List<String> smsSenders,
    required List<String> notificationPackages,
  }) async {
    if (!_isAndroid) return;
    await _channel.invokeMethod<void>('configure', {
      'smsEnabled': smsEnabled,
      'notificationEnabled': notificationEnabled,
      'smsSenders': smsSenders,
      'notificationPackages': notificationPackages,
    });
  }

  @override
  Future<List<NativeIngestionEvent>> pendingEvents() async {
    if (!_isAndroid) return const [];
    final result = await _channel.invokeListMethod<Object?>('pendingEvents');
    return (result ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(NativeIngestionEvent.fromMap)
        .toList();
  }

  @override
  Future<void> acknowledgeEvents(List<String> eventIds) async {
    if (_isAndroid && eventIds.isNotEmpty) {
      await _channel.invokeMethod<void>('acknowledgeEvents', eventIds);
    }
  }
}
