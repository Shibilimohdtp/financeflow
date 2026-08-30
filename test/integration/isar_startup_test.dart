import 'dart:ffi';
import 'dart:io';

import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/database/isar_service.dart';
import 'package:financeflow/database/schemas/account_entity.dart';
import 'package:financeflow/database/schemas/app_settings_entity.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isWindows) {
      await Isar.initializeIsarCore(
        libraries: {
          Abi.current():
              '${Platform.environment['LOCALAPPDATA']}'
              '/Pub/Cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/windows/isar.dll',
        },
      );
    } else {
      await Isar.initializeIsarCore(download: true);
    }
  });

  test(
    'open failure preserves existing database and permits a later retry',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'financeflow_bad_db_',
      );
      try {
        final database = File('${directory.path}/financeflow_local_db.isar');
        // Larger than MDBX's minimum file size, so this is rejected as an
        // invalid existing database rather than treated as a new empty file.
        final originalBytes = List<int>.filled(65536, 42);
        await database.writeAsBytes(originalBytes);
        await expectLater(
          IsarService.initialize(directoryPath: directory.path),
          throwsA(isA<DatabaseError>()),
        );
        expect(IsarService.isInitialized, isFalse);
        expect(await database.readAsBytes(), originalBytes);
        await expectLater(
          IsarService.initialize(directoryPath: directory.path),
          throwsA(isA<DatabaseError>()),
        );
        expect(await database.readAsBytes(), originalBytes);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'concurrent initialization shares one open and seed operation',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'financeflow_startup_',
      );
      Isar? database;
      try {
        final first = IsarService.initialize(directoryPath: directory.path);
        final second = IsarService.initialize(directoryPath: directory.path);
        expect(identical(first, second), isTrue);
        final services = await Future.wait([first, second]);
        expect(identical(services[0], services[1]), isTrue);
        database = services.first.isar;
        expect(await database.accountEntitys.count(), 1);
        expect(await database.appSettingsEntitys.count(), 1);
        expect(
          await IsarService.initialize(directoryPath: directory.path),
          services.first,
        );
        final settingsRepository = IsarSettingsRepository(
          isarInstance: database,
        );
        // The first app route must not wait on the native watch callback.
        expect(await settingsRepository.watchSettings().first, isNotNull);
      } finally {
        await database?.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
