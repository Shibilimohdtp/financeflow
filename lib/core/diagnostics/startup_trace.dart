import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Visible in Android logcat even when no Dart debugger is attached.
/// Only fixed milestone labels belong here, never settings or financial data.
void startupTrace(String milestone) {
  if (kDebugMode) debugPrint('[FinanceFlowStartup] $milestone');
}

/// Marks a rendered application route, not merely the loading/splash frame.
class StartupReady extends StatefulWidget {
  const StartupReady({super.key, required this.child});

  final Widget child;

  @override
  State<StartupReady> createState() => _StartupReadyState();
}

class _StartupReadyState extends State<StartupReady> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) startupTrace('Application route ready');
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
