# FinanceFlow

**A private, local-first personal finance app for India, built with Flutter.**
It tracks accounts, budgets, loans, subscriptions and savings goals, and can turn bank SMS alerts and notifications into transactions on the device itself.

> Status: personal project in active development. Android-first, not published on any app store. The code is public so it can be reviewed.

## Why it exists
Most finance apps want a server, an account and your data. FinanceFlow keeps everything on the phone: there is no backend, no sign-up, no analytics SDK, and the app declares no `INTERNET` permission in its main Android manifest.

## Features

| Area | What it does | Status |
|---|---|---|
| Accounts and transactions | Income, expense and transfer between owned accounts, categories, tags, notes, search and filters | Implemented |
| Automatic capture (Android) | Reads bank SMS and payment notifications on the device, parses them, and queues them in a **Needs review** inbox that you approve or dismiss. Bank-specific patterns for Axis, HDFC, SBI, ICICI and Federal Bank | Implemented |
| CSV import / export | Bank statement import with column mapping and presets; export of your data | Implemented |
| Budgets | Category budgets with spend pace and near-limit warnings | Implemented |
| Savings goals | Targets, contributions and on-track status | Implemented |
| Loans and EMIs | Loan schedules, payments, overdue states | Implemented |
| Money lent / borrowed | Person-wise lending records with FIFO repayment allocation | Implemented |
| Subscriptions | Recurring charges and renewal reminders | Implemented |
| Investments | Holdings and returns | Implemented |
| Insights | Cash-flow dashboard, analytics, financial health and alerts | Implemented |
| Security | Biometric / PIN app lock | Implemented |
| Backup and restore | Passphrase-encrypted backup file; restore by merging or replacing, with a preview first | Implemented |
| Gmail statement ingestion | Read statements from email | **Planned, not built** |
| Import from other finance apps | | **Planned, not built** |
| Encryption of the on-device database | See [Privacy and security](#privacy-and-security) | **Planned** |
| Multiple currencies | Currency is currently fixed to INR | **Planned** |

## Privacy and security
- **No server and no network permission.** Data is stored in a local Isar database. There is no cloud sync, account or telemetry.
- **Backups are encrypted.** A backup file uses AES-256 in CTR mode with a key derived from your passphrase using PBKDF2, a random salt and IV, and an HMAC. Without the passphrase the file cannot be read, and the passphrase cannot be recovered.
- **Be aware of the limits.** The on-device database itself is **not yet encrypted at rest**: it relies on the Android app sandbox plus the app lock. Android Auto Backup is not disabled yet. Both are on the roadmap.
- **SMS and notifications.** The app asks for SMS and notification access only to detect bank transaction messages. They are parsed on the device into structured fields. Nothing is sent anywhere.
- **Plaintext exports.** CSV export is plaintext by nature. Treat exported files like bank statements.
- All sample data in tests and screenshots is synthetic.

## Architecture
```
lib/
├── app/            # app shell, routing
├── core/           # constants and shared helpers
├── database/       # Isar schemas, migrations, database service
├── models/         # domain models (transactions, backup payload, ingestion)
├── repositories/   # data access over Isar
├── services/       # calculators and business logic (budgets, loans, analytics, ingestion, backup)
├── features/       # screens and controllers by feature
│   └── accounts, alerts, analytics, backup, budgets, dashboard, export,
│       financial_health, ingestion, investments, loans, personal_debts,
│       savings_goals, security, settings, subscriptions, transactions
├── shared/         # reusable widgets
└── theme/          # "Stillwater" design system tokens
android/.../kotlin/ # native SMS receiver and notification listener
```
- **State management:** Riverpod, with code generation where it helps.
- **Data flow for an SMS:** Android receiver → ingestion event → parser (bank-specific patterns) → pending transaction → **Needs review** queue → approved transaction; balances and budgets update.
- **Models:** Freezed and json_serializable for immutable models and backup serialisation.
- **Design system:** "Stillwater" (teal and sand with a marigold accent), documented in [`docs/design-system`](docs/design-system).

## Tech stack
Flutter and Dart · Riverpod · Isar · flutter_secure_storage and local_auth · flutter_local_notifications · Freezed and json_serializable · file_picker and share_plus.

## Testing
`flutter analyze` reports no issues. The suite has 128 test files (unit, widget and integration), run against synthetic data only.

Last full run (2026-11-24): **950 passed, 7 failed**. The 7 failures are widget tests whose expectations have drifted from the current UI copy or depend on today's date; they are known and listed here rather than hidden:
- `backup_screens_test.dart`: 3 tests (expected labels such as "100% Local" no longer match the screen)
- `subscriptions_screen_test.dart`, `subscription_detail_screen_test.dart`, `transaction_detail_screen_test.dart`: 1 test each (date-relative text such as "Later This Month" and "Renews in 3 days")
- `emi_schedule_view_test.dart`: 1 overflow check on narrow screens

```bash
flutter pub get
flutter analyze
flutter test
```

## Run the app
```bash
flutter pub get
flutter run            # Android device or emulator recommended
```
SMS and notification capture work on Android only. The iOS, macOS, Windows, Linux and web folders are default Flutter scaffolds. Use a test device or emulator with throwaway data rather than your real finances.

## Documentation
- [`docs/audit/2026-11-phase0-audit.md`](docs/audit/2026-11-phase0-audit.md): an honest engineering audit of the app, with a prioritised roadmap
- [`docs/architecture/`](docs/architecture): decisions on period handling and transaction semantics
- [`docs/features/`](docs/features): product requirements and ingestion notes
- [`AGENTS.md`](AGENTS.md): contributor rules, including the data-safety backup gate

## Known limitations
These are tracked in the audit document:
- Money amounts are stored as `double` (a decimal or integer-paise type is planned).
- Currency is fixed to INR and dates use the device time zone.
- Some aggregations are computed per screen instead of in one place, and large histories are not paged yet.
- The database is not encrypted at rest (see above).

## Author
Built by **Shibili Muhammed T P**.
[LinkedIn](https://www.linkedin.com/in/shibilimohdtp) · [Forma Studio](https://formastdio.com) · [GitHub](https://github.com/Shibilimohdtp)
