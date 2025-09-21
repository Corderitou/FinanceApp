import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  ReminderModel({
    super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.frequency,
    super.dayOfWeek,
    super.dayOfMonth,
    super.month,
    required super.time,
    super.isActive = true,
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

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
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
}