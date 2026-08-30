import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/services/notifications/notification_payload.dart';

void main() {
  group('NotificationPayload Tests', () {
    test('serializes and deserializes versioned payload correctly', () {
      const payload = NotificationPayload(
        version: 1,
        type: 'needs_review',
        entityId: 'pending_123',
        entityType: 'pending_review',
        route: '/needs-review',
        metadata: {'count': 2},
      );

      final encoded = payload.encode();
      final decoded = NotificationPayload.tryDecode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.version, equals(1));
      expect(decoded.type, equals('needs_review'));
      expect(decoded.entityId, equals('pending_123'));
      expect(decoded.entityType, equals('pending_review'));
      expect(decoded.route, equals('/needs-review'));
      expect(decoded.metadata['count'], equals(2));
      expect(decoded, equals(payload));
    });

    test('named factory constructors produce expected routes and metadata', () {
      final needsReview = NotificationPayload.needsReview(pendingId: 'tx_99');
      expect(needsReview.route, equals('/needs-review'));
      expect(needsReview.type, equals('needs_review'));
      expect(needsReview.entityId, equals('tx_99'));

      final budget = NotificationPayload.budget(budgetId: 'b_groceries');
      expect(budget.route, equals('/budgets'));
      expect(budget.type, equals('budget'));
      expect(budget.entityId, equals('b_groceries'));

      final sub = NotificationPayload.subscription(
        subscriptionId: 'sub_netflix',
      );
      expect(sub.route, equals('/subscriptions'));
      expect(sub.type, equals('subscription'));

      final loan = NotificationPayload.loan(loanId: 'loan_auto');
      expect(loan.route, equals('/loans'));
      expect(loan.type, equals('loan'));

      final backup = NotificationPayload.backup();
      expect(backup.route, equals('/backup'));

      final inbox = NotificationPayload.inbox();
      expect(inbox.route, equals('/alerts-inbox'));
    });

    test(
      'tryDecode safely handles invalid, corrupt, or empty JSON without throwing',
      () {
        expect(NotificationPayload.tryDecode(null), isNull);
        expect(NotificationPayload.tryDecode(''), isNull);
        expect(NotificationPayload.tryDecode('   '), isNull);
        expect(NotificationPayload.tryDecode('not valid json'), isNull);
        expect(NotificationPayload.tryDecode('12345'), isNull);
        expect(NotificationPayload.tryDecode('["array"]'), isNull);
      },
    );

    test(
      'tryDecode provides safe fallback defaults when fields are missing',
      () {
        const partialJson = '{"version": 1}';
        final decoded = NotificationPayload.tryDecode(partialJson);

        expect(decoded, isNotNull);
        expect(decoded!.version, equals(1));
        expect(decoded.type, equals('inbox'));
        expect(decoded.route, equals('/alerts-inbox'));
      },
    );
  });
}
