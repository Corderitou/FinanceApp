import '../../domain/entities/savings_goal.dart';

class SavingsGoalModel extends SavingsGoal {
  SavingsGoalModel({
    super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.targetAmount,
    required super.currentAmount,
    required super.targetDate,
    super.isCompleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  @override
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

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
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
}