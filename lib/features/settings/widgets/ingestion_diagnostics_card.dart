import 'package:flutter/material.dart';
import '../../../models/app_settings.dart';
import '../../../services/ingestion/ingestion_platform.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/ff.dart';

String _smsStatusLabel(IngestionPlatformStatus? status) {
  if (status == null) return 'Checking';
  switch (status.smsPermission) {
    case IngestionPermissionState.granted:
      return 'Granted';
    case IngestionPermissionState.denied:
      return 'Denied';
    case IngestionPermissionState.permanentlyDenied:
      return 'Permanently denied';
    case IngestionPermissionState.restricted:
      return 'Restricted';
    case IngestionPermissionState.unavailable:
      return 'Unavailable';
  }
}

String _ingestionTime(DateTime? value) {
  if (value == null) return 'Never';
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

class IngestionDiagnosticsCard extends StatelessWidget {
  final AppSettings settings;
  final IngestionPlatformStatus? ingestionStatus;
  final int awaitingReview;

  const IngestionDiagnosticsCard({
    super.key,
    required this.settings,
    required this.ingestionStatus,
    required this.awaitingReview,
  });

  @override
  Widget build(BuildContext context) {
    return FfCard(
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingestion diagnostics', style: context.ff.text.titleSm),
          const SizedBox(height: FfSpace.sm),
          Text(
            'SMS permission: ${_smsStatusLabel(ingestionStatus)}\n'
            'Notification access: ${ingestionStatus?.notificationAccess == true ? 'Allowed' : 'Not allowed'}\n'
            'Gmail connection: Not configured\n'
            'Last SMS event: ${_ingestionTime(settings.lastSuccessfulSmsEvent)}\n'
            'Last notification event: ${_ingestionTime(settings.lastSuccessfulNotificationEvent)}\n'
            'Last Gmail scan: Never\n'
            'Parsed: ${settings.ingestionParsedCount} · Rejected: ${settings.ingestionRejectedCount}\n'
            'Duplicates: ${settings.ingestionDuplicateCount} · Awaiting review: $awaitingReview\n'
            'Last error: ${settings.ingestionLastError ?? 'None'}',
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.secondary,
              height: 1.55,
            ),
          ),
          if (settings.isSmsDetectionEnabled &&
              ingestionStatus?.smsPermission !=
                  IngestionPermissionState.granted) ...[
            const SizedBox(height: FfSpace.sm),
            Text(
              'Action: open Bank SMS Detection and grant Android access.',
              style: context.ff.text.bodySm.copyWith(
                color: context.ff.color.statusError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
