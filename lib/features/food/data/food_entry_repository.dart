import 'package:sqflite/sqflite.dart';

import '../models/food_entry.dart';

class FoodEntryRepository {
  const FoodEntryRepository(this._database);

  final Database _database;

  Future<List<FoodEntry>> fetchAll() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'food_entries',
      orderBy: 'logged_at_utc_ms DESC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> insert(FoodEntry entry) async {
    await _database.insert(
      'food_entries',
      <String, Object?>{
        'id': entry.id,
        'name': entry.name,
        'calories_kcal': entry.caloriesKcal,
        'protein_g': entry.proteinGrams,
        'carbs_g': entry.carbsGrams,
        'fat_g': entry.fatGrams,
        'logged_at_utc_ms': entry.loggedAt.toUtc().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> delete(String id) async {
    await _database.delete(
      'food_entries',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  FoodEntry _fromRow(Map<String, Object?> row) {
    return FoodEntry(
      id: row['id'] as String,
      name: row['name'] as String,
      caloriesKcal: row['calories_kcal'] as int,
      proteinGrams: _nullableDouble(row['protein_g']),
      carbsGrams: _nullableDouble(row['carbs_g']),
      fatGrams: _nullableDouble(row['fat_g']),
      loggedAt: DateTime.fromMillisecondsSinceEpoch(
        row['logged_at_utc_ms'] as int,
        isUtc: true,
      ).toLocal(),
    );
  }

  double? _nullableDouble(Object? value) {
    return switch (value) {
      final num number => number.toDouble(),
      _ => null,
    };
  }
}
