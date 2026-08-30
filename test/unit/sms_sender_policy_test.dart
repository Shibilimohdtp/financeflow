import 'package:financeflow/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'migrates the former fixed sender defaults to financial-only policy',
    () {
      expect(
        restoreSmsSenderPolicy(const [
          'HDFCBK',
          'ICICIB',
          'SBIN',
          'AXISBK',
          'FEDBNK',
          'CANBNK',
          'UNIONB',
        ]),
        isEmpty,
      );
    },
  );

  test('preserves an explicit custom sender allow-list', () {
    expect(restoreSmsSenderPolicy(const ['HDFCBK']), ['HDFCBK']);
  });
}
