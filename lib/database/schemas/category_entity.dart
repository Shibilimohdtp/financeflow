import 'package:isar/isar.dart';

part 'category_entity.g.dart';

@collection
class CategoryEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(unique: true, caseSensitive: false)
  late String name;

  late String iconIdentifier;

  late String colorTokenIdentifier;

  List<String> typeCompatibility = ['expense']; // expense, income, transfer

  @Index()
  bool isDefault = true;

  @Index()
  bool isArchived = false;

  int sortOrder = 0;

  late DateTime createdAt;

  late DateTime updatedAt;
}
