import '../../domain/entities/category.dart' as entity;

class Category extends entity.Category {
  Category({
    super.id,
    required super.userId,
    required super.name,
    required super.type,
    super.color,
    super.icon,
    required super.createdAt,
    super.isSystemCategory,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'is_system_category': isSystemCategory ? 1 : 0,
    };
  }

  @override
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      color: map['color'],
      icon: map['icon'],
      createdAt: DateTime.parse(map['created_at']),
      isSystemCategory: map['is_system_category'] == 1,
    );
  }
}