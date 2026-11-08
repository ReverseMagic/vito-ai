import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/data/local_database.dart';
import '../data/water_log_repository.dart';
import '../models/water_log.dart';

final waterLogProvider =
    AsyncNotifierProvider<WaterLogNotifier, List<WaterLog>>(
  WaterLogNotifier.new,
);

class WaterLogNotifier extends AsyncNotifier<List<WaterLog>> {
  late WaterLogRepository _repository;

  @override
  Future<List<WaterLog>> build() async {
    final Database database = await ref.watch(localDatabaseProvider.future);
    _repository = WaterLogRepository(database);
    return _repository.fetchAll();
  }

  Future<void> add(WaterLog log) async {
    if (state.asData == null) {
      throw StateError('Water log is not ready.');
    }
    await _repository.insert(log);
    if (!ref.mounted) return;
    final List<WaterLog> current =
        state.asData?.value ?? const <WaterLog>[];
    state = AsyncValue<List<WaterLog>>.data(<WaterLog>[log, ...current]);
  }
}
