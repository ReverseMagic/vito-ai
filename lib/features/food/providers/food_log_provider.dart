import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/data/local_database.dart';
import '../data/food_entry_repository.dart';
import '../models/food_entry.dart';

final foodLogProvider =
    AsyncNotifierProvider<FoodLogNotifier, List<FoodEntry>>(
  FoodLogNotifier.new,
);

class FoodLogNotifier extends AsyncNotifier<List<FoodEntry>> {
  late FoodEntryRepository _repository;

  @override
  Future<List<FoodEntry>> build() async {
    final Database database = await ref.watch(localDatabaseProvider.future);
    _repository = FoodEntryRepository(database);
    return _repository.fetchAll();
  }

  Future<void> add(FoodEntry entry) async {
    final List<FoodEntry>? current = state.asData?.value;
    if (current == null) {
      throw StateError('Food log is not ready.');
    }
    await _repository.insert(entry);
    if (!ref.mounted) return;
    state = AsyncValue<List<FoodEntry>>.data(<FoodEntry>[entry, ...current]);
  }

  Future<void> remove(String id) async {
    final List<FoodEntry>? current = state.asData?.value;
    if (current == null) {
      throw StateError('Food log is not ready.');
    }
    await _repository.delete(id);
    if (!ref.mounted) return;
    state = AsyncValue<List<FoodEntry>>.data(
      current.where((FoodEntry entry) => entry.id != id).toList(),
    );
  }
}
