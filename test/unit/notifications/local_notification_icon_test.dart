import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification Icon Configuration & Resource Integrity (DS-B19c)', () {
    test('local_notification_service.dart wires @drawable/ic_notification and brand accent color', () {
      final file = File('lib/services/notifications/local_notification_service.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      // Assert default Android initialization settings
      expect(
        content.contains("AndroidInitializationSettings(\n        '@drawable/ic_notification',"),
        isTrue,
        reason: 'Android initialization settings must use @drawable/ic_notification, not @mipmap/ic_launcher',
      );

      // Assert immediate notification specifies ic_notification icon & brand color
      expect(
        content.contains("icon: '@drawable/ic_notification'"),
        isTrue,
        reason: 'AndroidNotificationDetails must specify ic_notification as the status bar small icon',
      );
      expect(
        content.contains('color: const Color(0xFF535B36)'),
        isTrue,
        reason: 'AndroidNotificationDetails must specify brand moss accent color',
      );
    });

    test('android/app/src/main/res/drawable/ic_notification.xml exists and is alpha-only', () {
      final xmlFile = File('android/app/src/main/res/drawable/ic_notification.xml');
      expect(xmlFile.existsSync(), isTrue);
      final xml = xmlFile.readAsStringSync();

      // Must be a 24dp vector
      expect(xml.contains('android:width="24dp"'), isTrue);
      expect(xml.contains('android:height="24dp"'), isTrue);

      // Must only contain white shapes (#FFFFFFFF or #FFFFFF) on transparent background
      final nonWhiteMatches = RegExp(r'#(?!FFF\b|FFFFFF\b|FFFFFFFF\b)[0-9A-Fa-f]{3,8}').allMatches(xml);
      expect(nonWhiteMatches.isEmpty, isTrue, reason: 'Status bar notification icon must be pure white alpha mask');
    });

    test('android/app/src/main/res/raw/keep.xml protects ic_notification from resource shrinking', () {
      final keepFile = File('android/app/src/main/res/raw/keep.xml');
      expect(keepFile.existsSync(), isTrue);
      final keepXml = keepFile.readAsStringSync();

      expect(keepXml.contains('@drawable/ic_notification'), isTrue);
      expect(keepXml.contains('@drawable/ic_launcher_foreground'), isTrue);
      expect(keepXml.contains('@drawable/ic_launcher_monochrome'), isTrue);
    });
  });
}
