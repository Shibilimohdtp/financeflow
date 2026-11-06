import 'package:flutter/material.dart';

/// Intent groups for settings.
enum SettingsGroup {
  appearance(
    label: 'Look & feel',
    description: 'Theme, display density and currency formatting',
    icon: Icons.palette_outlined,
  ),
  security(
    label: 'Privacy & security',
    description: 'App lock, biometrics, PIN and screen protection',
    icon: Icons.shield_outlined,
  ),
  alerts(
    label: 'Alerts & notifications',
    description: 'Local alert triggers, push notifications and privacy',
    icon: Icons.notifications_outlined,
  ),
  detection(
    label: 'Automatic detection',
    description: 'On-device bank SMS, notification parsing and CSV import',
    icon: Icons.sync_rounded,
  ),
  data(
    label: 'Data, backup & export',
    description: 'Encrypted backups, reports, file restoration and reset',
    icon: Icons.storage_rounded,
  ),
  about(
    label: 'About & system',
    description: 'App details, local-only guarantee and diagnostics',
    icon: Icons.info_outline_rounded,
  );

  const SettingsGroup({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}

/// Target destination or action for a settings entry.
enum SettingsDestination {
  appearance,
  themeSheet,
  density,
  currencySheet,
  security,
  pinSheet,
  biometrics,
  privacyBlur,
  screenshotProtection,
  autoLock,
  alerts,
  alertSettingsSheet,
  alertsInbox,
  detection,
  smsPermission,
  notificationPermission,
  csvImport,
  backup,
  restore,
  export,
  dangerZone,
  about,
  debugGallery,
}

/// A single searchable setting item in the settings surface.
class SettingsEntry {
  final String id;
  final String title;
  final String subtitle;
  final List<String> keywords;
  final SettingsGroup group;
  final IconData icon;
  final SettingsDestination destination;

  const SettingsEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.group,
    required this.icon,
    required this.destination,
  });

  bool matches(String query) {
    if (query.isEmpty) return false;
    final q = query.toLowerCase();
    if (title.toLowerCase().contains(q)) return true;
    if (subtitle.toLowerCase().contains(q)) return true;
    if (group.label.toLowerCase().contains(q)) return true;
    for (final kw in keywords) {
      if (kw.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}

/// Canonical in-memory index of every user-facing setting.
const List<SettingsEntry> kSettingsIndex = [
  // ── Appearance ─────────────────────────────────────────────────────────────
  SettingsEntry(
    id: 'theme',
    title: 'Theme',
    subtitle: 'System default, Daylight (Light), or Deep Water (Dark)',
    keywords: [
      'theme',
      'dark',
      'light',
      'daylight',
      'deep water',
      'mode',
      'color',
      'night',
    ],
    group: SettingsGroup.appearance,
    icon: Icons.palette_outlined,
    destination: SettingsDestination.themeSheet,
  ),
  SettingsEntry(
    id: 'density',
    title: 'Display density (Ledger view)',
    subtitle: 'Comfortable spacing or compact transaction rows',
    keywords: [
      'density',
      'compact',
      'ledger',
      'dense',
      'comfortable',
      'rows',
      'padding',
      'spacing',
    ],
    group: SettingsGroup.appearance,
    icon: Icons.density_medium_rounded,
    destination: SettingsDestination.density,
  ),
  SettingsEntry(
    id: 'currency',
    title: 'Currency display',
    subtitle: 'Change currency symbol and code formatting (no conversion)',
    keywords: [
      'currency',
      'rupee',
      'dollar',
      'euro',
      'inr',
      'usd',
      'symbol',
      'money',
      'code',
    ],
    group: SettingsGroup.appearance,
    icon: Icons.payments_outlined,
    destination: SettingsDestination.currencySheet,
  ),

  // ── Privacy & Security ─────────────────────────────────────────────────────
  SettingsEntry(
    id: 'pin_lock',
    title: 'App PIN lock',
    subtitle: 'Require a 4–6 digit security PIN to open FinanceFlow',
    keywords: [
      'pin',
      'lock',
      'passcode',
      'password',
      'code',
      'security',
      'keystore',
    ],
    group: SettingsGroup.security,
    icon: Icons.lock_outline_rounded,
    destination: SettingsDestination.pinSheet,
  ),
  SettingsEntry(
    id: 'biometric_unlock',
    title: 'Biometric authentication',
    subtitle: 'Unlock with Fingerprint or Face ID via hardware keystore',
    keywords: [
      'biometric',
      'fingerprint',
      'face id',
      'face',
      'touch',
      'unlock',
      'security',
    ],
    group: SettingsGroup.security,
    icon: Icons.fingerprint_rounded,
    destination: SettingsDestination.biometrics,
  ),
  SettingsEntry(
    id: 'privacy_blur',
    title: 'Privacy blur mode',
    subtitle: 'Mask financial balance figures by default across all screens',
    keywords: [
      'privacy',
      'blur',
      'hide',
      'mask',
      'amounts',
      'balance',
      'private',
      'eye',
    ],
    group: SettingsGroup.security,
    icon: Icons.blur_on_rounded,
    destination: SettingsDestination.privacyBlur,
  ),
  SettingsEntry(
    id: 'screenshot_protection',
    title: 'Screenshot & recents protection',
    subtitle: 'Block app preview screenshots in Android task switcher',
    keywords: [
      'screenshot',
      'recents',
      'task switcher',
      'capture',
      'security',
      'protect',
    ],
    group: SettingsGroup.security,
    icon: Icons.hide_image_outlined,
    destination: SettingsDestination.screenshotProtection,
  ),
  SettingsEntry(
    id: 'auto_lock',
    title: 'Auto-lock timeout',
    subtitle: 'Lock the app immediately or after background idle timeout',
    keywords: [
      'autolock',
      'auto lock',
      'timeout',
      'timer',
      'lock',
      'idle',
      'minutes',
    ],
    group: SettingsGroup.security,
    icon: Icons.timer_outlined,
    destination: SettingsDestination.autoLock,
  ),

  // ── Alerts & Notifications ─────────────────────────────────────────────────
  SettingsEntry(
    id: 'alerts_master',
    title: 'All alerts & notifications',
    subtitle: 'Master switch for 100% on-device alerts and local notifications',
    keywords: ['alerts', 'notifications', 'master', 'push', 'reminders', 'all'],
    group: SettingsGroup.alerts,
    icon: Icons.notifications_outlined,
    destination: SettingsDestination.alerts,
  ),
  SettingsEntry(
    id: 'needs_review_alerts',
    title: 'Needs review alerts',
    subtitle: 'Remind when imported SMS / CSV items require confirmation',
    keywords: [
      'needs review',
      'review',
      'pending',
      'imported',
      'transactions',
      'alerts',
    ],
    group: SettingsGroup.alerts,
    icon: Icons.rate_review_outlined,
    destination: SettingsDestination.alertSettingsSheet,
  ),
  SettingsEntry(
    id: 'budget_alerts',
    title: 'Budget limit alerts',
    subtitle: 'Alert when category spending approaches or exceeds plan',
    keywords: ['budget', 'limit', 'overspend', 'warning', 'alerts', 'pace'],
    group: SettingsGroup.alerts,
    icon: Icons.pie_chart_outline_rounded,
    destination: SettingsDestination.alertSettingsSheet,
  ),
  SettingsEntry(
    id: 'subscription_alerts',
    title: 'Subscription renewal alerts',
    subtitle: 'Remind before recurring subscriptions and services renew',
    keywords: [
      'subscription',
      'renewal',
      'recurring',
      'bill',
      'alerts',
      'burn rate',
    ],
    group: SettingsGroup.alerts,
    icon: Icons.repeat_rounded,
    destination: SettingsDestination.alertSettingsSheet,
  ),
  SettingsEntry(
    id: 'loan_alerts',
    title: 'Loan & EMI due date alerts',
    subtitle: 'Remind before upcoming loan EMIs and installments are due',
    keywords: ['loan', 'emi', 'due', 'debt', 'repayment', 'alerts'],
    group: SettingsGroup.alerts,
    icon: Icons.account_balance_outlined,
    destination: SettingsDestination.alertSettingsSheet,
  ),
  SettingsEntry(
    id: 'backup_reminders',
    title: 'Encrypted backup reminders',
    subtitle: 'Periodic reminder when 30 days have elapsed without a backup',
    keywords: [
      'backup reminder',
      'reminder',
      'schedule',
      'alerts',
      'freshness',
    ],
    group: SettingsGroup.alerts,
    icon: Icons.backup_outlined,
    destination: SettingsDestination.alertSettingsSheet,
  ),
  SettingsEntry(
    id: 'lock_screen_privacy',
    title: 'Lock screen privacy',
    subtitle: 'Hide sensitive merchant names and amounts on lock screen',
    keywords: [
      'lock screen',
      'sensitive',
      'privacy',
      'hide',
      'notification',
      'details',
      'preview',
    ],
    group: SettingsGroup.alerts,
    icon: Icons.visibility_off_outlined,
    destination: SettingsDestination.alertSettingsSheet,
  ),
  SettingsEntry(
    id: 'alerts_inbox',
    title: 'Local alerts inbox',
    subtitle: 'Dismissible timeline of on-device financial alerts',
    keywords: ['inbox', 'alerts inbox', 'notifications list', 'messages'],
    group: SettingsGroup.alerts,
    icon: Icons.notifications_active_outlined,
    destination: SettingsDestination.alertsInbox,
  ),

  // ── Automatic Detection ────────────────────────────────────────────────────
  SettingsEntry(
    id: 'sms_detection',
    title: 'Bank SMS detection',
    subtitle: 'Parse debit/credit transactions from Indian bank SMS offline',
    keywords: [
      'sms',
      'message',
      'text',
      'detection',
      'bank',
      'regex',
      'automatic',
      'ingestion',
    ],
    group: SettingsGroup.detection,
    icon: Icons.sms_outlined,
    destination: SettingsDestination.smsPermission,
  ),
  SettingsEntry(
    id: 'notification_detection',
    title: 'Payment app notification detection',
    subtitle:
        'Read incoming UPI notifications from Google Pay, PhonePe, Paytm, CRED',
    keywords: [
      'notification detection',
      'upi',
      'gpay',
      'phonepe',
      'paytm',
      'cred',
      'listener',
      'apps',
    ],
    group: SettingsGroup.detection,
    icon: Icons.notifications_active_outlined,
    destination: SettingsDestination.notificationPermission,
  ),
  SettingsEntry(
    id: 'csv_import',
    title: 'Import CSV statement',
    subtitle: 'Parse bank or credit card CSV statement files into local ledger',
    keywords: [
      'csv',
      'import',
      'statement',
      'bank statement',
      'excel',
      'upload',
      'file',
    ],
    group: SettingsGroup.detection,
    icon: Icons.file_upload_outlined,
    destination: SettingsDestination.csvImport,
  ),

  // ── Data, Backup & Export ──────────────────────────────────────────────────
  SettingsEntry(
    id: 'backup_create',
    title: 'Encrypted backup & migration',
    subtitle: 'Generate zero-knowledge AES-256 CTR encrypted backup archive',
    keywords: [
      'backup',
      'export backup',
      'encrypt',
      'aes',
      'save',
      'archive',
      'passphrase',
      'migration',
    ],
    group: SettingsGroup.data,
    icon: Icons.lock_clock_outlined,
    destination: SettingsDestination.backup,
  ),
  SettingsEntry(
    id: 'backup_restore',
    title: 'Restore from backup file',
    subtitle: 'Inspect and merge or clean-replace data from a .ffbackup file',
    keywords: [
      'restore',
      'recover',
      'import backup',
      'decrypt',
      'replace',
      'merge',
    ],
    group: SettingsGroup.data,
    icon: Icons.settings_backup_restore_rounded,
    destination: SettingsDestination.restore,
  ),
  SettingsEntry(
    id: 'export_reports',
    title: 'Export financial reports',
    subtitle:
        'Compile transactions into CSV or JSON spreadsheets strictly on-device',
    keywords: [
      'export',
      'reports',
      'csv export',
      'json export',
      'sheets',
      'tax',
      'download',
    ],
    group: SettingsGroup.data,
    icon: Icons.file_download_outlined,
    destination: SettingsDestination.export,
  ),
  SettingsEntry(
    id: 'data_reset',
    title: 'Wipe all app data (Danger zone)',
    subtitle:
        'Permanently delete all stored financial records and security keys from device',
    keywords: [
      'reset',
      'wipe',
      'delete',
      'clear',
      'erase',
      'danger',
      'factory reset',
    ],
    group: SettingsGroup.data,
    icon: Icons.delete_forever_outlined,
    destination: SettingsDestination.dangerZone,
  ),

  // ── About ──────────────────────────────────────────────────────────────────
  SettingsEntry(
    id: 'about_app',
    title: 'About FinanceFlow',
    subtitle:
        'Version details, 100% on-device architecture, and open source licenses',
    keywords: [
      'about',
      'version',
      'build',
      'license',
      'offline',
      'credits',
      'info',
    ],
    group: SettingsGroup.about,
    icon: Icons.info_outline_rounded,
    destination: SettingsDestination.about,
  ),
];

/// Searches the settings index in-memory in zero time.
List<SettingsEntry> searchSettings(String query) {
  final clean = query.trim().toLowerCase();
  if (clean.isEmpty) return const [];
  return kSettingsIndex.where((entry) => entry.matches(clean)).toList();
}
