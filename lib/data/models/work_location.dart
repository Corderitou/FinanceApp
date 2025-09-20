import 'package:ingresos_costos_app/domain/entities/work_location.dart';

class WorkLocationModel extends WorkLocation {
  WorkLocationModel({
    int? id,
    required int userId,
    required String name,
    double? latitude,
    double? longitude,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          latitude: latitude,
          longitude: longitude,
          date: date,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory WorkLocationModel.fromMap(Map<String, dynamic> map) {
    return WorkLocationModel(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      latitude: map['latitude'] != null ? map['latitude'].toDouble() : null,
      longitude: map['longitude'] != null ? map['longitude'].toDouble() : null,
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory WorkLocationModel.fromEntity(WorkLocation entity) {
    return WorkLocationModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      date: entity.date,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}