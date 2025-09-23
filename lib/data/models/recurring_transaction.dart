import '../../domain/entities/recurring_transaction.dart' as entity;

class RecurringTransaction extends entity.RecurringTransaction {
  RecurringTransaction({
    super.id,
    required super.userId,
    super.accountId,
    super.categoryId,
    required super.amount,
    required super.type,
    super.description,
    required super.frequency,
    super.dayOfWeek,
    super.dayOfMonth,
    super.month,
    required super.startDate,
    super.endDate,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'frequency': frequency,
      'day_of_week': dayOfWeek,
      'day_of_month': dayOfMonth,
      'month': month,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      accountId: map['account_id']?.toInt(),
      categoryId: map['category_id']?.toInt(),
      amount: map['amount']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      description: map['description'],
      frequency: map['frequency'] ?? '',
      dayOfWeek: map['day_of_week']?.toInt(),
      dayOfMonth: map['day_of_month']?.toInt(),
      month: map['month']?.toInt(),
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}