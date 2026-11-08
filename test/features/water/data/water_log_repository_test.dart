import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vito_ai/features/water/data/water_log_repository.dart';
import 'package:vito_ai/features/water/models/water_log.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database database;
  late WaterLogRepository repository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE water_logs (
              id TEXT PRIMARY KEY NOT NULL,
              volume_ml INTEGER NOT NULL CHECK (volume_ml > 0),
              logged_at_utc_ms INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
    repository = WaterLogRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists and reads water intake in millilitres', () async {
    final WaterLog log = WaterLog(
      id: 'water-1',
      volumeMl: 250,
      loggedAt: DateTime(2026, 11, 8, 9),
    );

    await repository.insert(log);
    final List<WaterLog> logs = await repository.fetchAll();

    expect(logs, hasLength(1));
    expect(logs.single.volumeMl, 250);
    expect(logs.single.id, 'water-1');
  });
}
