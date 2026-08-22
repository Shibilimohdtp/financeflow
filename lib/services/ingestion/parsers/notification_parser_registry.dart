import '../../../models/ingestion/parsed_transaction.dart';
import 'notification_parsers.dart';

class NotificationParserRegistry {
  final List<NotificationParser> _parsers;

  NotificationParserRegistry([List<NotificationParser>? parsers])
    : _parsers =
          parsers ??
          [
            GooglePayNotificationParser(),
            PhonePeNotificationParser(),
            PaytmNotificationParser(),
            CredNotificationParser(),
            GenericBankNotificationParser(),
          ];

  void registerParser(NotificationParser parser) {
    _parsers.insert(0, parser);
  }

  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    for (final parser in _parsers) {
      if (parser.canParse(packageName, title, text)) {
        final result = parser.parse(
          packageName: packageName,
          title: title,
          text: text,
          timestamp: timestamp,
          defaultAccountId: defaultAccountId,
        );
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }
}
