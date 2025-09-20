import '../../domain/entities/transaction.dart' as entity;

class Transaction extends entity.Transaction {
  Transaction({
    super.id,
    required super.userId,
    required super.accountId,
    required super.categoryId,
    required super.amount,
    required super.type,
    super.description,
    required super.date,
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
}