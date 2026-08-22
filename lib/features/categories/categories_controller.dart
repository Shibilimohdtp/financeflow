import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../settings/settings_controller.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
});

final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categories = ref.watch(categoriesStreamProvider).value ?? [];
  try {
    return categories.firstWhere((cat) => cat.id == id);
  } catch (_) {
    return null;
  }
});
