class Account {
  final int? id;
  final int userId;
  final String name;
  final String type; // savings, checking, credit, etc.
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    double? balance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      balance: map['balance']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, name: $name, type: $type, balance: $balance, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Account &&
      other.id == id &&
      other.userId == userId &&
      other.name == name &&
      other.type == type &&
      other.balance == balance &&
      other.currency == currency &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      balance.hashCode ^
      currency.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}