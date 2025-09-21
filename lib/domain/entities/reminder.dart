class Reminder {
  final int? id;
  final int userId;
  final String name;
  final String? description;
  final String frequency; // daily, weekly, monthly, yearly
  final int? dayOfWeek; // 1-7 (Monday-Sunday), null for daily
  final int? dayOfMonth; // 1-31, null for daily/weekly
  final int? month; // 1-12, null for daily/weekly/monthly
  final String time; // HH:MM format
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.month,
    required this.time,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Reminder copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    String? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    int? month,
    String? time,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      month: month ?? this.month,
      time: time ?? this.time,
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
      'frequency': frequency,
      'day_of_week': dayOfWeek,
      'day_of_month': dayOfMonth,
      'month': month,
      'time': time,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'],
      frequency: map['frequency'] ?? '',
      dayOfWeek: map['day_of_week']?.toInt(),
      dayOfMonth: map['day_of_month']?.toInt(),
      month: map['month']?.toInt(),
      time: map['time'] ?? '',
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, userId: $userId, name: $name, description: $description, frequency: $frequency, dayOfWeek: $dayOfWeek, dayOfMonth: $dayOfMonth, month: $month, time: $time, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Reminder &&
      other.id == id &&
      other.userId == userId &&
      other.name == name &&
      other.description == description &&
      other.frequency == frequency &&
      other.dayOfWeek == dayOfWeek &&
      other.dayOfMonth == dayOfMonth &&
      other.month == month &&
      other.time == time &&
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
      frequency.hashCode ^
      dayOfWeek.hashCode ^
      dayOfMonth.hashCode ^
      month.hashCode ^
      time.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}