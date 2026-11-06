import 'package:flutter/material.dart';

import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_banner.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../add_advance_sheet.dart';

/// Collision hint banner shown when a record for this person and direction already exists.
class MoneyRecordCollisionBanner extends StatelessWidget {
  const MoneyRecordCollisionBanner({
    super.key,
    required this.collisionMatch,
    required this.type,
  });

  final MoneyRecord collisionMatch;
  final MoneyRecordType type;

  @override
  Widget build(BuildContext context) {
    return FfBanner(
      tone: FfBannerTone.info,
      message:
          '${collisionMatch.personName} already has an open ${type.shortName.toLowerCase()} record. Add an advance to that ledger instead?',
      actionLabel: 'Add Advance',
      onAction: () {
        Navigator.of(context).pop();
        showFfSheet(
          context,
          builder: (_) => AddAdvanceSheet(record: collisionMatch),
        );
      },
    );
  }
}
