import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final localDatabaseProvider = FutureProvider<Database>((ref) async {
  final String databaseDirectory = await getDatabasesPath();
  final Database database = await openDatabase(
    '$databaseDirectory/vito_ai.db',
    version: 2,
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE food_entries (
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT NOT NULL CHECK (length(trim(name)) > 0),
          calories_kcal INTEGER NOT NULL CHECK (calories_kcal >= 0),
          protein_g REAL NULL CHECK (protein_g IS NULL OR protein_g >= 0),
          carbs_g REAL NULL CHECK (carbs_g IS NULL OR carbs_g >= 0),
          fat_g REAL NULL CHECK (fat_g IS NULL OR fat_g >= 0),
          sugar_total_g REAL NULL CHECK (sugar_total_g IS NULL OR sugar_total_g >= 0),
          fiber_g REAL NULL CHECK (fiber_g IS NULL OR fiber_g >= 0),
          sodium_mg REAL NULL CHECK (sodium_mg IS NULL OR sodium_mg >= 0),
          logged_at_utc_ms INTEGER NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_food_entries_logged_at '
        'ON food_entries(logged_at_utc_ms DESC)',
      );
      await _createWaterLogsTable(db);
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
          'ALTER TABLE food_entries ADD COLUMN sugar_total_g REAL NULL '
          'CHECK (sugar_total_g IS NULL OR sugar_total_g >= 0)',
        );
        await db.execute(
          'ALTER TABLE food_entries ADD COLUMN fiber_g REAL NULL '
          'CHECK (fiber_g IS NULL OR fiber_g >= 0)',
        );
        await db.execute(
          'ALTER TABLE food_entries ADD COLUMN sodium_mg REAL NULL '
          'CHECK (sodium_mg IS NULL OR sodium_mg >= 0)',
        );
        await _createWaterLogsTable(db);
      }
    },
  );
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

Future<void> _createWaterLogsTable(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE water_logs (
      id TEXT PRIMARY KEY NOT NULL,
      volume_ml INTEGER NOT NULL CHECK (volume_ml > 0),
      logged_at_utc_ms INTEGER NOT NULL
    )
  ''');
  await db.execute(
    'CREATE INDEX idx_water_logs_logged_at '
    'ON water_logs(logged_at_utc_ms DESC)',
  );
}
