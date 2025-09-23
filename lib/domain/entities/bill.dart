class Bill {
  final int? id;
  final int userId;
  final String name;
  final String? description;
  final double? amount; // Expected amount (if fixed)
  final int? accountId; // Account this bill is associated with
  final int? categoryId; // Category for this bill
  final int? dayOfMonth; // Due day of month (1-31)
  final DateTime? dueDate; // Specific due date (if not recurring)
  final String frequency; // 'monthly', 'quarterly', 'yearly', 'once'
  final DateTime startDate; // When this bill started
  final DateTime? endDate; // When this bill ends (if applicable)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    this.amount,
    this.accountId,
    this.categoryId,
    this.dayOfMonth,
    this.dueDate,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Bill copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    double? amount,
    int? accountId,
    int? categoryId,
    int? dayOfMonth,
    DateTime? dueDate,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dueDate: dueDate ?? this.dueDate,
      frequency: frequency ?? this.frequency,
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

  @override
  String toString() {
    return 'Bill(id: $id, userId: $userId, name: $name, description: $description, amount: $amount, accountId: $accountId, categoryId: $categoryId, dayOfMonth: $dayOfMonth, dueDate: $dueDate, frequency: $frequency, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Bill &&
      other.id == id &&
      other.userId == userId &&
      other.name == name &&
      other.description == description &&
      other.amount == amount &&
      other.accountId == accountId &&
      other.categoryId == categoryId &&
      other.dayOfMonth == dayOfMonth &&
      other.dueDate == dueDate &&
      other.frequency == frequency &&
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
      name.hashCode ^
      description.hashCode ^
      amount.hashCode ^
      accountId.hashCode ^
      categoryId.hashCode ^
      dayOfMonth.hashCode ^
      dueDate.hashCode ^
      frequency.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}