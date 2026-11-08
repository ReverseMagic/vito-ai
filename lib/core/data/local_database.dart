import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final localDatabaseProvider = FutureProvider<Database>((ref) async {
  final String databaseDirectory = await getDatabasesPath();
  final Database database = await openDatabase(
    '$databaseDirectory/vito_ai.db',
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE food_entries (
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT NOT NULL CHECK (length(trim(name)) > 0),
          calories_kcal INTEGER NOT NULL CHECK (calories_kcal >= 0),
          protein_g REAL NULL CHECK (protein_g IS NULL OR protein_g >= 0),
          carbs_g REAL NULL CHECK (carbs_g IS NULL OR carbs_g >= 0),
          fat_g REAL NULL CHECK (fat_g IS NULL OR fat_g >= 0),
          logged_at_utc_ms INTEGER NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_food_entries_logged_at '
        'ON food_entries(logged_at_utc_ms DESC)',
      );
    },
  );
  ref.onDispose(() => database.close());
  return database;
});
