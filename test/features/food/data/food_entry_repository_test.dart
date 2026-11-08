import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vito_ai/features/food/data/food_entry_repository.dart';
import 'package:vito_ai/features/food/models/food_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database database;
  late FoodEntryRepository repository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE food_entries (
              id TEXT PRIMARY KEY NOT NULL,
              name TEXT NOT NULL CHECK (length(trim(name)) > 0),
              calories_kcal INTEGER NOT NULL CHECK (calories_kcal >= 0),
              protein_g REAL NULL,
              carbs_g REAL NULL,
              fat_g REAL NULL,
              sugar_total_g REAL NULL,
              fiber_g REAL NULL,
              sodium_mg REAL NULL,
              logged_at_utc_ms INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
    repository = FoodEntryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists and reads a food entry with nutrient values', () async {
    final FoodEntry entry = FoodEntry(
      id: 'entry-1',
      name: 'Oats',
      caloriesKcal: 150,
      carbsGrams: 27,
      proteinGrams: 5,
      fatGrams: 3,
      sugarTotalGrams: 1,
      fiberGrams: 4,
      sodiumMg: 2,
      loggedAt: DateTime(2026, 11, 8, 8),
    );

    await repository.insert(entry);
    final List<FoodEntry> entries = await repository.fetchAll();

    expect(entries, hasLength(1));
    expect(entries.single.name, 'Oats');
    expect(entries.single.caloriesKcal, 150);
    expect(entries.single.proteinGrams, 5);
    expect(entries.single.sugarTotalGrams, 1);
    expect(entries.single.fiberGrams, 4);
    expect(entries.single.sodiumMg, 2);
  });

  test('preserves unknown nutrient values as null', () async {
    final FoodEntry entry = FoodEntry(
      id: 'entry-2',
      name: 'Apple',
      caloriesKcal: 95,
      carbsGrams: null,
      proteinGrams: null,
      fatGrams: null,
      sugarTotalGrams: null,
      fiberGrams: null,
      sodiumMg: null,
      loggedAt: DateTime(2026, 11, 8, 9),
    );

    await repository.insert(entry);
    final FoodEntry saved = (await repository.fetchAll()).single;

    expect(saved.carbsGrams, isNull);
    expect(saved.proteinGrams, isNull);
    expect(saved.fatGrams, isNull);
    expect(saved.sugarTotalGrams, isNull);
    expect(saved.fiberGrams, isNull);
    expect(saved.sodiumMg, isNull);
  });

  test('deletes an entry by id', () async {
    final FoodEntry entry = FoodEntry(
      id: 'entry-3',
      name: 'Banana',
      caloriesKcal: 105,
      carbsGrams: null,
      proteinGrams: null,
      fatGrams: null,
      sugarTotalGrams: null,
      fiberGrams: null,
      sodiumMg: null,
      loggedAt: DateTime(2026, 11, 8, 10),
    );

    await repository.insert(entry);
    await repository.delete(entry.id);

    expect(await repository.fetchAll(), isEmpty);
  });
}
