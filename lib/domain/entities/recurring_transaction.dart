class RecurringTransaction {
  final int? id;
  final int userId;
  final int? accountId;
  final int? categoryId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? description;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final int? dayOfWeek; // 1-7 (Monday-Sunday), used for weekly
  final int? dayOfMonth; // 1-31, used for monthly/yearly
  final int? month; // 1-12, used for yearly
  final DateTime startDate;
  final DateTime? endDate; // null means no end date
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecurringTransaction({
    this.id,
    required this.userId,
    this.accountId,
    this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.month,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTransaction copyWith({
    int? id,
    int? userId,
    int? accountId,
    int? categoryId,
    double? amount,
    String? type,
    String? description,
    String? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    int? month,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      month: month ?? this.month,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  @override
  String toString() {
    return 'RecurringTransaction(id: $id, userId: $userId, accountId: $accountId, categoryId: $categoryId, amount: $amount, type: $type, description: $description, frequency: $frequency, dayOfWeek: $dayOfWeek, dayOfMonth: $dayOfMonth, month: $month, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is RecurringTransaction &&
      other.id == id &&
      other.userId == userId &&
      other.accountId == accountId &&
      other.categoryId == categoryId &&
      other.amount == amount &&
      other.type == type &&
      other.description == description &&
      other.frequency == frequency &&
      other.dayOfWeek == dayOfWeek &&
      other.dayOfMonth == dayOfMonth &&
      other.month == month &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.isActive == isActive &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      accountId.hashCode ^
      categoryId.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      description.hashCode ^
      frequency.hashCode ^
      dayOfWeek.hashCode ^
      dayOfMonth.hashCode ^
      month.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}