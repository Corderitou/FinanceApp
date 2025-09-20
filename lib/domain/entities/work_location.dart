class WorkLocation {
  final int? id;
  final int userId;
  final String name;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkLocation({
    this.id,
    required this.userId,
    required this.name,
    this.latitude,
    this.longitude,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkLocation copyWith({
    int? id,
    int? userId,
    String? name,
    double? latitude,
    double? longitude,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  factory WorkLocation.fromMap(Map<String, dynamic> map) {
    return WorkLocation(
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

  @override
  String toString() {
    return 'WorkLocation(id: $id, userId: $userId, name: $name, latitude: $latitude, longitude: $longitude, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is WorkLocation &&
      other.id == id &&
      other.userId == userId &&
      other.name == name &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.date == date &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      date.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}