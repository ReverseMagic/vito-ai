import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_entry.dart';

final foodLogProvider =
    NotifierProvider<FoodLogNotifier, List<FoodEntry>>(FoodLogNotifier.new);

class FoodLogNotifier extends Notifier<List<FoodEntry>> {
  @override
  List<FoodEntry> build() => const <FoodEntry>[];

  void add(FoodEntry entry) => state = <FoodEntry>[entry, ...state];

  void remove(String id) {
    state = state.where((FoodEntry entry) => entry.id != id).toList();
  }
}
