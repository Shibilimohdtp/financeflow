import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/diagnostics/startup_trace.dart';
import 'database/isar_service.dart';
import 'shared/widgets/financeflow_mark.dart';
import 'theme/stillwater_theme.dart';

/// This must stay synchronous. Android removes its launch window when Flutter
/// draws its first frame; awaiting a plugin or database before [runApp] can
/// otherwise leave a cold-started app on the native splash indefinitely.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startupTrace('Dart main entered');
  runApp(ProviderScope(child: StartupApp(initialize: _initializeDatabase)));
  startupTrace('runApp submitted');
}

Future<void> _initializeDatabase() async {
  await IsarService.initialize();
}

class StartupApp extends StatefulWidget {
  const StartupApp({
    super.key,
    required this.initialize,
    this.child = const FinanceFlowApp(),
    this.timeout = const Duration(seconds: 12),
  });

  final Future<void> Function() initialize;
  final Widget child;
  final Duration timeout;

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  Future<Object?>? _startup;
  Future<void>? _attempt;

  @override
  void initState() {
    super.initState();
    // Render loading feedback before any plugin/native database work begins.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _retry();
    });
  }

  Future<Object?> _waitForDatabase() async {
    try {
      // Keep the real attempt after a UI timeout. A retry joins it until it
      // settles; only a completed failure permits another initialization.
      final attempt =
          _attempt ??= Future<void>.sync(
            widget.initialize,
          ).whenComplete(() => _attempt = null);
      await attempt.timeout(widget.timeout);
      startupTrace('Local database ready');
      return null;
    } catch (error) {
      startupTrace('Local database unavailable');
      // The next frame may not have subscribed to FutureBuilder yet. Carry
      // failures as data so fast failures/retries cannot become unhandled
      // asynchronous errors before that frame (or after this widget is gone).
      return error;
    }
  }

  void _retry() {
    startupTrace('Waiting for local database');
    setState(() {
      _startup = _waitForDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == null) {
          return widget.child;
        }
        return MaterialApp(
          title: 'FinanceFlow',
          debugShowCheckedModeBanner: false,
          theme: StillwaterTheme.daylight,
          darkTheme: StillwaterTheme.deepWater,
          home: _StartupScreen(
            error: snapshot.connectionState == ConnectionState.done
                ? snapshot.data
                : null,
            onRetry: _retry,
          ),
        );
      },
    );
  }
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
