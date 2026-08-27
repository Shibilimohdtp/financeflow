import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'database/isar_service.dart';
import 'shared/widgets/financeflow_mark.dart';
import 'theme/stillwater_theme.dart';

/// This must stay synchronous. Android removes its launch window when Flutter
/// draws its first frame; awaiting a plugin or database before [runApp] can
/// otherwise leave a cold-started app on the native splash indefinitely.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _startupLog('Dart main entered; submitting the first Flutter frame.');
  runApp(const ProviderScope(child: _StartupApp()));
  _startupLog('runApp submitted.');
}

class _StartupApp extends StatefulWidget {
  const _StartupApp();

  @override
  State<_StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<_StartupApp> {
  static const _databaseStartupTimeout = Duration(seconds: 12);
  late Future<void> _startup;

  @override
  void initState() {
    super.initState();
    _startupLog('Starting local database initialization.');
    _startup = _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await IsarService.initialize().timeout(
        _databaseStartupTimeout,
        onTimeout: () => throw StateError(
          'The local database took too long to open. Please try again.',
        ),
      );
      _startupLog('Local database initialization completed.');
    } catch (error, stackTrace) {
      _startupLog('Local database initialization failed: $error',
          error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  void _retry() {
    _startupLog('Retrying local database initialization.');
    setState(() {
      _startup = _initializeDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const FinanceFlowApp();
        }
        return MaterialApp(
          title: 'FinanceFlow',
          debugShowCheckedModeBanner: false,
          theme: StillwaterTheme.daylight,
          darkTheme: StillwaterTheme.deepWater,
          home: _StartupScreen(error: snapshot.error, onRetry: _retry),
        );
      },
    );
  }
}

void _startupLog(
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  developer.log(
    message,
    name: 'FinanceFlowStartup',
    error: error,
    stackTrace: stackTrace,
  );
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FinanceFlowLogo(
                markSize: 64,
                fontSize: 26,
                showTagline: true,
                axis: Axis.vertical,
              ),
              const SizedBox(height: 28),
              if (!hasError) const CircularProgressIndicator(),
              if (!hasError) ...[
                const SizedBox(height: 16),
                const Text('Preparing your local data…'),
              ] else ...[
                const Text(
                  'FinanceFlow could not open its local data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your data has not been changed. Try again to continue.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
