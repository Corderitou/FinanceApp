class Category {
  final int? id;
  final int userId;
  final String name;
  final String type; // income or expense
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final bool isSystemCategory; // Flag to identify system categories

  Category({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.color,
    this.icon,
    required this.createdAt,
    this.isSystemCategory = false, // Default to false for user categories
  });

  Category copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    String? color,
    String? icon,
    DateTime? createdAt,
    bool? isSystemCategory,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      isSystemCategory: isSystemCategory ?? this.isSystemCategory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'is_system_category': isSystemCategory ? 1 : 0, // Store as integer in database
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      color: map['color'],
      icon: map['icon'],
      createdAt: DateTime.parse(map['created_at']),
      isSystemCategory: map['is_system_category'] == 1, // Read as boolean
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, userId: $userId, name: $name, type: $type, color: $color, icon: $icon, createdAt: $createdAt, isSystemCategory: $isSystemCategory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Category &&
      other.id == id &&
      other.userId == userId &&
      other.name == name &&
      other.type == type &&
      other.color == color &&
      other.icon == icon &&
      other.createdAt == createdAt &&
      other.isSystemCategory == isSystemCategory;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      color.hashCode ^
      icon.hashCode ^
      createdAt.hashCode ^
      isSystemCategory.hashCode;
  }
}