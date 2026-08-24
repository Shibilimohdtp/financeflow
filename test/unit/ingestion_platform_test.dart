import 'package:financeflow/services/ingestion/ingestion_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android ingestion permission mapping', () {
    for (final state in IngestionPermissionState.values) {
      test('maps ${state.name}', () {
        final status = IngestionPlatformStatus.fromMap({
          'platform': 'android',
          'smsAvailable': true,
          'smsStatus': state.name,
          'notificationAccess': true,
        });

        expect(status.isAndroid, isTrue);
        expect(status.smsAvailable, isTrue);
        expect(status.smsPermission, state);
        expect(status.notificationAccess, isTrue);
      });
    }

    test('unknown native state is safely unavailable', () {
      final status = IngestionPlatformStatus.fromMap(const {
        'platform': 'android',
        'smsStatus': 'futureAndroidState',
      });
      expect(status.smsPermission, IngestionPermissionState.unavailable);
    });
  });
}
