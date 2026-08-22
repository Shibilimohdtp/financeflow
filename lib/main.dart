import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'database/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local-first Isar database on device
  await IsarService.initialize();

  runApp(const ProviderScope(child: FinanceFlowApp()));
}
