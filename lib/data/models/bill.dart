import '../../domain/entities/bill.dart' as entity;

class Bill extends entity.Bill {
  Bill({
    super.id,
    required super.userId,
    required super.name,
    super.description,
    super.amount,
    super.accountId,
    super.categoryId,
    super.dayOfMonth,
    super.dueDate,
    required super.frequency,
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
      'name': name,
      'description': description,
      'amount': amount,
      'account_id': accountId,
      'category_id': categoryId,
      'day_of_month': dayOfMonth,
      'due_date': dueDate?.toIso8601String(),
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'],
      amount: map['amount']?.toDouble(),
      accountId: map['account_id']?.toInt(),
      categoryId: map['category_id']?.toInt(),
      dayOfMonth: map['day_of_month']?.toInt(),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      frequency: map['frequency'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}