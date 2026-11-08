import 'package:sqflite/sqflite.dart';

import '../models/water_log.dart';

class WaterLogRepository {
  const WaterLogRepository(this._database);

  final Database _database;

  Future<List<WaterLog>> fetchAll() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'water_logs',
      orderBy: 'logged_at_utc_ms DESC',
    );
    return rows.map((Map<String, Object?> row) {
      return WaterLog(
        id: row['id'] as String,
        volumeMl: row['volume_ml'] as int,
        loggedAt: DateTime.fromMillisecondsSinceEpoch(
          row['logged_at_utc_ms'] as int,
          isUtc: true,
        ).toLocal(),
      );
    }).toList(growable: false);
  }

  Future<void> insert(WaterLog log) async {
    await _database.insert(
      'water_logs',
      <String, Object?>{
        'id': log.id,
        'volume_ml': log.volumeMl,
        'logged_at_utc_ms': log.loggedAt.toUtc().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
