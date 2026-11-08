import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vito_ai/features/food/models/food_entry.dart';
import 'package:vito_ai/features/food/providers/food_log_provider.dart';

void main() {
  group('FoodLogNotifier', () {
    test('adds and removes entries', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      const FoodEntry entry = FoodEntry(
        id: 'entry-1',
        name: 'Oats',
        caloriesKcal: 150,
        carbsGrams: 27,
        proteinGrams: 5,
        fatGrams: 3,
        loggedAt: DateTime(2026, 11, 8),
      );

      container.read(foodLogProvider.notifier).add(entry);
      expect(container.read(foodLogProvider), <FoodEntry>[entry]);

      container.read(foodLogProvider.notifier).remove('entry-1');
      expect(container.read(foodLogProvider), isEmpty);
    });

    test('keeps unknown nutrients as null', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      const FoodEntry entry = FoodEntry(
        id: 'entry-2',
        name: 'Apple',
        caloriesKcal: 95,
        carbsGrams: null,
        proteinGrams: null,
        fatGrams: null,
        loggedAt: DateTime(2026, 11, 8),
      );

      container.read(foodLogProvider.notifier).add(entry);
      expect(container.read(foodLogProvider).single.carbsGrams, isNull);
    });
  });
}
