class Category {
  final String id;
  final String name;
  final String iconIdentifier;
  final String colorTokenIdentifier;
  final List<String> typeCompatibility;
  final bool isDefault;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.iconIdentifier,
    required this.colorTokenIdentifier,
    this.typeCompatibility = const ['expense'],
    this.isDefault = true,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconIdentifier,
    String? colorTokenIdentifier,
    List<String>? typeCompatibility,
    bool? isDefault,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconIdentifier: iconIdentifier ?? this.iconIdentifier,
      colorTokenIdentifier: colorTokenIdentifier ?? this.colorTokenIdentifier,
      typeCompatibility: typeCompatibility ?? this.typeCompatibility,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
