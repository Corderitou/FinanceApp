class SavingsGoal {
  final int? id;
  final int userId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsGoal({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SavingsGoal copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'],
      targetAmount: map['target_amount']?.toDouble() ?? 0.0,
      currentAmount: map['current_amount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(map['target_date']),
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'SavingsGoal(id: $id, userId: $userId, name: $name, description: $description, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SavingsGoal &&
      other.id == id &&
      other.userId == userId &&
      other.name == name &&
      other.description == description &&
      other.targetAmount == targetAmount &&
      other.currentAmount == currentAmount &&
      other.targetDate == targetDate &&
      other.isCompleted == isCompleted &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      targetAmount.hashCode ^
      currentAmount.hashCode ^
      targetDate.hashCode ^
      isCompleted.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}