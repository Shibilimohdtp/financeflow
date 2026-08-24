import 'package:financeflow/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  test(
    'ingestion settings and diagnostics persist through repository',
    () async {
      final repository = FakeSettingsRepository();
      final eventTime = DateTime(2026, 8, 24, 10, 30);

      await repository.updateSettings(
        AppSettings(
          isSmsDetectionEnabled: true,
          isNotificationDetectionEnabled: true,
          selectedSmsSenders: const ['HDFCBK'],
          selectedNotificationPackages: const ['com.phonepe.app'],
          lastSuccessfulSmsEvent: eventTime,
          ingestionParsedCount: 4,
          ingestionRejectedCount: 2,
          ingestionDuplicateCount: 1,
          ingestionLastError: 'ExampleError',
        ),
      );

      final restored = await repository.getSettings();
      expect(restored.isSmsDetectionEnabled, isTrue);
      expect(restored.isNotificationDetectionEnabled, isTrue);
      expect(restored.selectedSmsSenders, ['HDFCBK']);
      expect(restored.selectedNotificationPackages, ['com.phonepe.app']);
      expect(restored.lastSuccessfulSmsEvent, eventTime);
      expect(restored.ingestionParsedCount, 4);
      expect(restored.ingestionRejectedCount, 2);
      expect(restored.ingestionDuplicateCount, 1);
      expect(restored.ingestionLastError, 'ExampleError');
      repository.dispose();
    },
  );
}
