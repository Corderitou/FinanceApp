import 'package:ingresos_costos_app/data/database/database_helper.dart';
import 'package:ingresos_costos_app/data/models/work_location.dart';
import 'package:ingresos_costos_app/domain/entities/work_location.dart';

abstract class WorkLocationRepository {
  Future<List<WorkLocation>> getWorkLocationsByUserId(int userId);
  Future<List<WorkLocation>> getFrequentWorkLocationsByUserId(int userId, {int limit = 5});
  Future<WorkLocation?> getWorkLocationById(int id);
  Future<WorkLocation> addWorkLocation(WorkLocation workLocation);
  Future<WorkLocation> updateWorkLocation(WorkLocation workLocation);
  Future<void> deleteWorkLocation(int id);
}

class WorkLocationRepositoryImpl implements WorkLocationRepository {
  final DatabaseHelper dbHelper;

  WorkLocationRepositoryImpl({required this.dbHelper});

  @override
  Future<List<WorkLocation>> getWorkLocationsByUserId(int userId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'work_locations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => WorkLocationModel.fromMap(map)).toList();
  }

  @override
  Future<List<WorkLocation>> getFrequentWorkLocationsByUserId(int userId, {int limit = 5}) async {
    final db = await dbHelper.db;
    
    // Get all work locations for the user
    final List<Map<String, dynamic>> allMaps = await db.query(
      'work_locations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Convert to WorkLocation objects
    final allLocations = allMaps.map((map) => WorkLocationModel.fromMap(map)).toList();
    
    // Group by name and count occurrences
    final Map<String, int> locationCounts = {};
    for (var location in allLocations) {
      locationCounts[location.name] = (locationCounts[location.name] ?? 0) + 1;
    }
    
    // Sort by frequency (most frequent first)
    final sortedLocations = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get top N most frequent locations (default 5)
    final topLocations = sortedLocations.take(limit).map((entry) {
      // Find the first location with this name to use as a template
      return allLocations.firstWhere((loc) => loc.name == entry.key);
    }).toList();
    
    return topLocations;
  }

  @override
  Future<WorkLocation?> getWorkLocationById(int id) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'work_locations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return WorkLocationModel.fromMap(maps.first);
  }

  @override
  Future<WorkLocation> addWorkLocation(WorkLocation workLocation) async {
    final db = await dbHelper.db;
    final workLocationMap = WorkLocationModel.fromEntity(workLocation).toMap();
    
    // Remove the id field for insertion
    workLocationMap.remove('id');
    
    final id = await db.insert('work_locations', workLocationMap);
    
    return workLocation.copyWith(id: id);
  }

  @override
  Future<WorkLocation> updateWorkLocation(WorkLocation workLocation) async {
    final db = await dbHelper.db;
    final workLocationMap = WorkLocationModel.fromEntity(workLocation).toMap();
    
    // Remove the id field from the map as it's used in the where clause
    final id = workLocationMap.remove('id');
    
    await db.update(
      'work_locations',
      workLocationMap,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    return workLocation;
  }

  @override
  Future<void> deleteWorkLocation(int id) async {
    final db = await dbHelper.db;
    await db.delete(
      'work_locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}