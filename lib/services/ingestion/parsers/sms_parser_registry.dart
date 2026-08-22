import '../../../models/ingestion/parsed_transaction.dart';
import 'sms_parsers.dart';

class SmsParserRegistry {
  final List<SmsParser> _parsers;

  SmsParserRegistry([List<SmsParser>? parsers])
    : _parsers =
          parsers ??
          [
            HdfcSmsParser(),
            IciciSmsParser(),
            SbiSmsParser(),
            AxisSmsParser(),
            FederalSmsParser(),
            CanaraSmsParser(),
            UnionBankSmsParser(),
            GenericUpiSmsParser(),
          ];

  void registerParser(SmsParser parser) {
    _parsers.insert(0, parser);
  }

  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    for (final parser in _parsers) {
      if (parser.canParse(sender, body)) {
        final result = parser.parse(
          sender: sender,
          body: body,
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
