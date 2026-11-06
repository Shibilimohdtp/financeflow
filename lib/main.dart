import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/diagnostics/startup_trace.dart';
import 'database/isar_service.dart';
import 'shared/widgets/ff_button.dart';
import 'shared/widgets/ff_card.dart';
import 'shared/widgets/ff_surfaces.dart';
import 'shared/widgets/financeflow_mark.dart';
import 'theme/ff.dart';
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
  Future<void>? _observedAttempt;
  bool _timedOut = false;

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
      _resumeWhenAttemptCompletes(attempt);
      await attempt.timeout(widget.timeout);
      _timedOut = false;
      startupTrace('Local database ready');
      return null;
    } catch (error) {
      _timedOut = error is TimeoutException;
      startupTrace('Local database unavailable');
      // The next frame may not have subscribed to FutureBuilder yet. Carry
      // failures as data so fast failures/retries cannot become unhandled
      // asynchronous errors before that frame (or after this widget is gone).
      return error;
    }
  }

  /// A timeout only stops waiting in the UI; it cannot cancel a native Isar
  /// open. If that open eventually succeeds, resume automatically instead of
  /// leaving the cold-start screen waiting for the user to press Retry again.
  void _resumeWhenAttemptCompletes(Future<void> attempt) {
    if (identical(_observedAttempt, attempt)) return;
    _observedAttempt = attempt;
    unawaited(
      attempt.then(
        (_) {
          if (!mounted || !_timedOut) return;
          startupTrace('Local database completed after wait');
          setState(() {
            _timedOut = false;
            _startup = Future<Object?>.value(null);
          });
        },
        onError: (_, __) {
          // _waitForDatabase presents completed failures to the user. Keeping
          // this handler prevents a late failed attempt from becoming unhandled.
        },
      ),
    );
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
            error:
                snapshot.connectionState == ConnectionState.done
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
    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
            child: hasError
                ? FfCard(
                    padding: const EdgeInsets.all(FfSpace.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FinanceFlowMark(size: 56),
                        const SizedBox(height: FfSpace.lg),
                        Text(
                          'FinanceFlow could not open its local data.',
                          textAlign: TextAlign.center,
                          style: context.ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: FfSpace.xs),
                        Text(
                          'Your data has not been changed. Try again to continue.',
                          textAlign: TextAlign.center,
                          style: context.ff.text.bodySm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                        const SizedBox(height: FfSpace.xl),
                        FfButton(
                          label: 'Try again',
                          leadingIcon: const Icon(Icons.refresh_rounded, size: 18),
                          onPressed: onRetry,
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FinanceFlowLogo(
                        markSize: 64,
                        fontSize: 26,
                        showTagline: true,
                        axis: Axis.vertical,
                      ),
                      const SizedBox(height: FfSpace.x2l),
                      SizedBox.square(
                        dimension: FfProgressTokens.spinnerSize,
                        child: CircularProgressIndicator(
                          strokeWidth: FfProgressTokens.spinnerStroke,
                          color: context.ff.color.actionPrimary,
                          semanticsLabel: 'Preparing your local data…',
                        ),
                      ),
                      const SizedBox(height: FfSpace.md),
                      Text(
                        'Preparing your local data…',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
