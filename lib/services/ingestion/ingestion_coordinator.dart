import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../repositories/settings_repository.dart';
import '../notifications/notification_coordinator.dart';
import 'ingestion_platform.dart';
import 'ingestion_service.dart';

final ingestionPlatformProvider = Provider<IngestionPlatform>((ref) {
  return MethodChannelIngestionPlatform();
});

final ingestionPlatformStatusProvider =
    StateProvider<AsyncValue<IngestionPlatformStatus>>((ref) {
      return const AsyncValue.loading();
    });

final ingestionCoordinatorProvider = Provider<IngestionCoordinator>((ref) {
  final coordinator = IngestionCoordinator(
    ref: ref,
    platform: ref.watch(ingestionPlatformProvider),
    ingestionService: ref.watch(ingestionServiceProvider),
  );
  ref.listen<AsyncValue<AppSettings>>(settingsStreamProvider, (previous, next) {
    final before = previous?.asData?.value;
    next.whenData((settings) {
      if (before == null ||
          before.isSmsDetectionEnabled != settings.isSmsDetectionEnabled ||
          before.isNotificationDetectionEnabled !=
              settings.isNotificationDetectionEnabled ||
          before.selectedSmsSenders.join('|') !=
              settings.selectedSmsSenders.join('|') ||
          before.selectedNotificationPackages.join('|') !=
              settings.selectedNotificationPackages.join('|')) {
        coordinator.scheduleConfigure(settings);
      }
    });
  }, fireImmediately: true);
  coordinator.start();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

class IngestionCoordinator with WidgetsBindingObserver {
  final Ref _ref;
  final IngestionPlatform _platform;
  final IngestionService _ingestionService;
  bool _processing = false;
  StreamSubscription<void>? _eventSubscription;
  Future<void> _configurationBarrier = Future.value();

  IngestionCoordinator({
    required Ref ref,
    required IngestionPlatform platform,
    required IngestionService ingestionService,
  }) : _ref = ref,
       _platform = platform,
       _ingestionService = ingestionService;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _eventSubscription = _platform.eventsAvailable.listen((_) {
      unawaited(processPendingNativeEvents());
    });
    unawaited(refreshStatusAndProcess());
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_eventSubscription?.cancel());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshStatusAndProcess());
    }
  }

  Future<void> configure(AppSettings settings) {
    return _platform.configure(
      smsEnabled: settings.isSmsDetectionEnabled,
      notificationEnabled: settings.isNotificationDetectionEnabled,
      smsSenders: settings.selectedSmsSenders,
      notificationPackages: settings.selectedNotificationPackages,
    );
  }

  /// Serializes native preference writes so a settings update cannot be
  /// overwritten by an older stream emission.  Draining after the write also
  /// covers events captured while Flutter was starting.
  void scheduleConfigure(AppSettings settings) {
    _configurationBarrier = _configurationBarrier
        .catchError((_) {})
        .then<void>((_) => configure(settings));
    unawaited(
      _configurationBarrier
          .then((_) => processPendingNativeEvents())
          .catchError((_) {}),
    );
  }

  Future<IngestionPlatformStatus> refreshStatus() async {
    try {
      final status = await _platform.getStatus();
      _ref
          .read(ingestionPlatformStatusProvider.notifier)
          .state = AsyncValue.data(status);
      return status;
    } catch (error, stack) {
      _ref
          .read(ingestionPlatformStatusProvider.notifier)
          .state = AsyncValue.error(error, stack);
      rethrow;
    }
  }

  Future<IngestionPlatformStatus> requestSmsPermission() async {
    final status = await _platform.requestSmsPermission();
    _ref.read(ingestionPlatformStatusProvider.notifier).state = AsyncValue.data(
      status,
    );
    return status;
  }

  Future<void> openAppSettings() => _platform.openAppSettings();

  Future<void> openNotificationAccessSettings() =>
      _platform.openNotificationAccessSettings();

  Future<void> refreshStatusAndProcess() async {
    await refreshStatus();
    try {
      await _configurationBarrier;
    } catch (error, stack) {
      _ref.read(ingestionPlatformStatusProvider.notifier).state =
          AsyncValue.error(error, stack);
    }
    await processPendingNativeEvents();
  }

  Future<void> processPendingNativeEvents() async {
    if (_processing) return;
    _processing = true;
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      var settings = await settingsRepo.getSettings();
      final events = await _platform.pendingEvents();
      for (final event in events) {
        try {
          IngestionResult? result;
          if (event.type == 'sms' && settings.isSmsDetectionEnabled) {
            result = await _ingestionService.ingestSms(
              sender: event.payload['sender'] as String? ?? '',
              body: event.payload['body'] as String? ?? '',
              timestamp: _timestamp(event.payload['timestamp']),
              sourceIdentifier: event.eventId,
            );
          } else if (event.type == 'notification' &&
              settings.isNotificationDetectionEnabled &&
              settings.selectedNotificationPackages.contains(
                event.payload['packageName'],
              )) {
            result = await _ingestionService.ingestNotification(
              packageName: event.payload['packageName'] as String? ?? '',
              title: event.payload['title'] as String? ?? '',
              text: event.payload['text'] as String? ?? '',
              timestamp: _timestamp(event.payload['timestamp']),
              sourceIdentifier: event.eventId,
            );
          }

          if (result != null) {
            settings = _updatedDiagnostics(settings, event.type, result);
            await settingsRepo.updateSettings(settings);
          }
          // Disabled/removed sources are intentionally discarded on drain.
          await _platform.acknowledgeEvents([event.eventId]);
        } catch (error) {
          // Keep the event queued for a later retry; record only the error type,
          // never the sensitive payload.
          settings = settings.copyWith(
            ingestionLastError: 'Event processing failed: ${error.runtimeType}',
          );
          await settingsRepo.updateSettings(settings);
          break;
        }
      }
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
    } finally {
      _processing = false;
    }
  }

  Future<IngestionResult> injectSampleSms() async {
    final result = await _ingestionService.ingestSms(
      sender: 'HDFCBK',
      body:
          'HDFC Bank: Rs 1500.00 debited from a/c **4321 on 22-AUG-26 to SWIGGY. UPI Ref 42352345.',
      timestamp: DateTime.now(),
      sourceIdentifier:
          'developer-sms-${DateTime.now().microsecondsSinceEpoch}',
    );
    await _recordInjected('sms', result);
    try {
      await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
    } catch (_) {}
    return result;
  }

  Future<IngestionResult> injectSampleNotification() async {
    final result = await _ingestionService.ingestNotification(
      packageName: 'com.google.android.apps.nbu.paisa.user',
      title: 'Google Pay',
      text: 'Paid ₹325 to Uber successfully',
      timestamp: DateTime.now(),
      sourceIdentifier:
          'developer-notification-${DateTime.now().microsecondsSinceEpoch}',
    );
    await _recordInjected('notification', result);
    try {
      await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
    } catch (_) {}
    return result;
  }

  Future<void> _recordInjected(String type, IngestionResult result) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final current = await repo.getSettings();
    await repo.updateSettings(_updatedDiagnostics(current, type, result));
  }

  AppSettings _updatedDiagnostics(
    AppSettings current,
    String type,
    IngestionResult result,
  ) {
    final successful = result.disposition != IngestionDisposition.rejected;
    return current.copyWith(
      lastIngestionScan: DateTime.now(),
      lastSuccessfulSmsEvent:
          successful && type == 'sms'
              ? DateTime.now()
              : current.lastSuccessfulSmsEvent,
      lastSuccessfulNotificationEvent:
          successful && type == 'notification'
              ? DateTime.now()
              : current.lastSuccessfulNotificationEvent,
      ingestionParsedCount: current.ingestionParsedCount + (successful ? 1 : 0),
      ingestionRejectedCount:
          current.ingestionRejectedCount + (successful ? 0 : 1),
      ingestionDuplicateCount:
          current.ingestionDuplicateCount +
          (result.disposition == IngestionDisposition.duplicate ? 1 : 0),
    );
  }

  DateTime? _timestamp(Object? value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}
