# Transaction Ingestion Implementation Status

Last updated: 2026-08-30

## Current behavior

FinanceFlow keeps parsers and financial persistence in Dart/Isar. Android owns
only permission checks, early candidate filtering, and a bounded private event
queue. SMS and notification contents are never written to logs or sent to an
external API.

Real-time events use this policy:

- Valid, high-confidence, non-duplicate transactions are committed immediately.
- Warnings, medium-confidence items, and duplicates are placed in Needs Review.
- A financial candidate that has an unfamiliar or incomplete format is placed
  in Needs Review with a local-only warning instead of being dropped.
- Isar transaction and pending streams update the UI without an app restart.

## Feature matrix

| Source | Status | Notes |
|---|---|---|
| Android bank SMS | Implemented | New messages only; requires runtime SMS permission and an enabled source. Operator-prefixed sender IDs and unfamiliar bank IDs are accepted only after the private OTP/promo + financial-candidate gate; unknown formats go to Needs Review. |
| Android payment notifications | Implemented | Requires Notification Access in Android Settings and a selected package. |
| Gmail bank email | Not implemented | The UI says “Not configured”; there is no OAuth or Gmail reader in this build. |
| CSV | Implemented | Review-based CSV import. XLSX, OFX, and QIF remain unavailable. |
| Manual | Implemented | Saves through the normal transaction repository. |

## Android manual test procedure

1. Install a fresh debug build and complete onboarding.
2. Open More → App Settings → Bank SMS Detection.
3. Tap enable and grant both requested SMS permissions. Confirm diagnostics says
   `Granted`. Deny once and verify detection stays off. Deny permanently and
   verify the screen directs the user to App Settings.
4. Open Notification Detection, select the desired payment apps, and open
   Android Notification Access. Enable FinanceFlow, return to the app, and tap
   Enable. Confirm diagnostics says `Allowed`.
5. Expand Developer Tools and inject the sample SMS and notification. Verify a
   high-confidence item appears immediately in Transactions and a repeated or
   uncertain item appears in Needs Review.
6. Send a realistic HDFC, ICICI, SBI, Axis, Federal, Canara, Union Bank, other
   bank, UPI, or card debit alert. Verify amount, direction, merchant, date,
   and reference in the transaction detail or review item. A new bank wording
   must be visible in Needs Review even if it cannot be fully parsed.
7. Trigger a notification for the same payment and verify it is not committed a
   second time. Resolve it in Needs Review.
8. Disable each source and confirm subsequent events are ignored.
9. Re-enable the sources, background or swipe away the app, then receive a new
   event. Relaunch FinanceFlow and confirm the private native queue is processed.
   Repeat while the app is foregrounded to verify the queue is drained after its
   durable write, not before it.
10. Reboot and repeat step 9. Android re-registers the manifest SMS receiver and
    rebinds an enabled notification listener; OEM battery policies can delay this.
11. Force-stop FinanceFlow from Android Settings. Confirm no capture occurs until
    the app is manually launched again; this is an Android platform restriction.

Do not paste real message bodies into bug reports. Use the sample injectors and
the aggregate diagnostics counters instead.

## Platform and distribution limits

- SMS and notification-listener ingestion are Android-only. iOS does not expose
  another app's notifications or the SMS inbox to FinanceFlow.
- `READ_SMS` and `RECEIVE_SMS` are restricted by Google Play. A Play release must
  meet an allowed core-use-case policy and pass the permissions declaration
  process. Otherwise distribute without SMS ingestion or through an appropriate
  non-Play/managed channel.
- Notification access is a special user-granted Android setting, not the Android
  13 `POST_NOTIFICATIONS` runtime permission. The latter only controls
  notifications posted by FinanceFlow itself.
- A foreground service is not used: `SMS_RECEIVED` is a manifest broadcast and
  the notification listener is bound by Android. This avoids a permanent status
  notification and unnecessary battery cost.
- Gmail acquisition would require network access, Google OAuth, the narrow
  `gmail.readonly` scope, secure token storage, sender/subject-limited queries,
  message-ID persistence, local parsing, and Google OAuth verification. No Gmail
  content may be sent to Gemini or another external service.
