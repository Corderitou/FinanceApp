class Transaction {
  final int? id;
  final int userId;
  final int accountId;
  final int categoryId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    int? id,
    int? userId,
    int? accountId,
    int? categoryId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
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
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      accountId: map['account_id']?.toInt() ?? 0,
      categoryId: map['category_id']?.toInt() ?? 0,
      amount: map['amount']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      description: map['description'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, accountId: $accountId, categoryId: $categoryId, amount: $amount, type: $type, description: $description, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Transaction &&
      other.id == id &&
      other.userId == userId &&
      other.accountId == accountId &&
      other.categoryId == categoryId &&
      other.amount == amount &&
      other.type == type &&
      other.description == description &&
      other.date == date &&
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
      date.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}