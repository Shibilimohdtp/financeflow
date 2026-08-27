import 'dart:convert';

/// Versioned payload attached to local notifications for deep linking and event tracing.
class NotificationPayload {
  final int version;
  final String type;
  final String? entityId;
  final String? entityType;
  final String route;
  final Map<String, dynamic> metadata;

  const NotificationPayload({
    this.version = 1,
    required this.type,
    this.entityId,
    this.entityType,
    required this.route,
    this.metadata = const {},
  });

  factory NotificationPayload.needsReview({String? pendingId}) {
    return NotificationPayload(
      version: 1,
      type: 'needs_review',
      entityId: pendingId ?? 'pending_review_batch',
      entityType: 'pending_review',
      route: '/needs-review',
      metadata: pendingId != null ? {'pendingId': pendingId} : const {},
    );
  }

  factory NotificationPayload.budget({required String budgetId}) {
    return NotificationPayload(
      version: 1,
      type: 'budget',
      entityId: budgetId,
      entityType: 'budget',
      route: '/budgets',
      metadata: {'budgetId': budgetId},
    );
  }

  factory NotificationPayload.subscription({required String subscriptionId}) {
    return NotificationPayload(
      version: 1,
      type: 'subscription',
      entityId: subscriptionId,
      entityType: 'subscription',
      route: '/subscriptions',
      metadata: {'subscriptionId': subscriptionId},
    );
  }

  factory NotificationPayload.loan({required String loanId}) {
    return NotificationPayload(
      version: 1,
      type: 'loan',
      entityId: loanId,
      entityType: 'loan',
      route: '/loans',
      metadata: {'loanId': loanId},
    );
  }

  factory NotificationPayload.backup() {
    return const NotificationPayload(
      version: 1,
      type: 'backup',
      entityId: 'backup_schedule',
      entityType: 'backup',
      route: '/backup',
    );
  }

  factory NotificationPayload.inbox() {
    return const NotificationPayload(
      version: 1,
      type: 'inbox',
      entityId: 'inbox',
      entityType: 'inbox',
      route: '/alerts-inbox',
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'type': type,
    'entityId': entityId,
    'entityType': entityType,
    'route': route,
    'metadata': metadata,
  };

  String encode() => jsonEncode(toJson());

  static NotificationPayload? tryDecode(String? rawPayload) {
    if (rawPayload == null || rawPayload.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) return null;

      final version = decoded['version'] as int? ?? 1;
      final type = decoded['type'] as String? ?? 'inbox';
      final entityId = decoded['entityId'] as String?;
      final entityType = decoded['entityType'] as String?;
      final route = decoded['route'] as String? ?? '/alerts-inbox';
      final metadata =
          decoded['metadata'] is Map<String, dynamic>
              ? decoded['metadata'] as Map<String, dynamic>
              : <String, dynamic>{};

      return NotificationPayload(
        version: version,
        type: type,
        entityId: entityId,
        entityType: entityType,
        route: route,
        metadata: metadata,
      );
    } catch (_) {
      // Graceful fallback on malformed or legacy payloads
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPayload &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          type == other.type &&
          entityId == other.entityId &&
          entityType == other.entityType &&
          route == other.route;

  @override
  int get hashCode =>
      version.hashCode ^
      type.hashCode ^
      (entityId?.hashCode ?? 0) ^
      (entityType?.hashCode ?? 0) ^
      route.hashCode;
}
