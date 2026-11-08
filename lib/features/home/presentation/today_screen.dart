import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/food/models/food_entry.dart';
import '../../../features/food/providers/food_log_provider.dart';
import '../../../features/water/models/water_log.dart';
import '../../../features/water/providers/water_log_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final AsyncValue<List<FoodEntry>> foodState = ref.watch(foodLogProvider);
    final AsyncValue<List<WaterLog>> waterState = ref.watch(waterLogProvider);

    return foodState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(s.dataLoadFailed, textAlign: TextAlign.center),
        ),
      ),
      data: (List<FoodEntry> allEntries) {
        final DateTime now = DateTime.now();
        final List<FoodEntry> entries = allEntries.where((FoodEntry entry) =>
          _sameDay(entry.loggedAt, now),
        ).toList(growable: false);
        final int calories = entries.fold<int>(
          0,
          (int total, FoodEntry entry) => total + entry.caloriesKcal,
        );
        final double? protein =
            _completeTotal(entries, (FoodEntry e) => e.proteinGrams);
        final double? carbs =
            _completeTotal(entries, (FoodEntry e) => e.carbsGrams);
        final double? fat =
            _completeTotal(entries, (FoodEntry e) => e.fatGrams);
        final double? sugar =
            _completeTotal(entries, (FoodEntry e) => e.sugarTotalGrams);
        final double? fiber =
            _completeTotal(entries, (FoodEntry e) => e.fiberGrams);
        final double? sodium =
            _completeTotal(entries, (FoodEntry e) => e.sodiumMg);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(s.todayEyebrow,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  letterSpacing: 1.1,
                                )),
                        const SizedBox(height: 5),
                        Text(s.goodDay,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Icon(Icons.person_outline),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _CaloriesCard(calories: calories, entryCount: entries.length),
              const SizedBox(height: 25),
              Text(s.nutrition,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(child: _NutrientCard(label: s.protein, value: protein, unit: 'g')),
                  const SizedBox(width: 9),
                  Expanded(child: _NutrientCard(label: s.carbs, value: carbs, unit: 'g')),
                  const SizedBox(width: 9),
                  Expanded(child: _NutrientCard(label: s.fat, value: fat, unit: 'g')),
                ],
              ),
              const SizedBox(height: 16),
              Text(s.otherNutrients,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: _NutrientCard(label: s.sugar, value: sugar, unit: 'g')),
                  const SizedBox(width: 9),
                  Expanded(child: _NutrientCard(label: s.fiber, value: fiber, unit: 'g')),
                  const SizedBox(width: 9),
                  Expanded(child: _NutrientCard(label: s.sodium, value: sodium, unit: 'mg')),
                ],
              ),
              const SizedBox(height: 20),
              waterState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (Object error, StackTrace stack) => Text(s.dataLoadFailed),
                data: (List<WaterLog> logs) {
                  final int waterMl = logs
                      .where((WaterLog log) => _sameDay(log.loggedAt, now))
                      .fold<int>(0, (int total, WaterLog log) => total + log.volumeMl);
                  return _WaterCard(
                    totalMl: waterMl,
                    onAdd: () async {
                      final WaterLog log = WaterLog(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        volumeMl: 250,
                        loggedAt: DateTime.now(),
                      );
                      try {
                        await ref.read(waterLogProvider.notifier).add(log);
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.saveFailed)),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 25),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(s.recentMeals,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                  ),
                  TextButton(
                    onPressed: () => context.go('/diary'),
                    child: Text(s.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                _EmptyMealsCard(
                  title: s.noMealsYet,
                  subtitle: s.startWithFirstMeal,
                  actionLabel: s.addFood,
                  onAdd: () => context.push('/add-food'),
                )
              else
                ...entries.take(3).map(
                  (FoodEntry entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFECECE8),
                          child: Icon(Icons.restaurant_outlined,
                              color: Color(0xFF151515)),
                        ),
                        title: Text(entry.name),
                        subtitle: Text('${entry.caloriesKcal} kcal'),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => context.push('/add-food'),
                  icon: const Icon(Icons.add),
                  label: Text(s.logFood),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  double? _completeTotal(
    List<FoodEntry> entries,
    double? Function(FoodEntry) valueOf,
  ) {
    if (entries.isEmpty ||
        entries.any((FoodEntry entry) => valueOf(entry) == null)) {
      return null;
    }
    return entries.fold<double>(
      0,
      (double total, FoodEntry entry) => total + valueOf(entry)!,
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.calories, required this.entryCount});

  final int calories;
  final int entryCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.caloriesToday,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: 0,
                          strokeWidth: 9,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),
                      ),
                      const Icon(Icons.local_fire_department_outlined, size: 30),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(calories.toString(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.5,
                              )),
                      Text(s.kcalConsumed,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                      const SizedBox(height: 10),
                      Text(s.goalNotSet,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: Theme.of(context).dividerColor),
            Row(
              children: <Widget>[
                Icon(Icons.restaurant_outlined,
                    size: 17, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(s.mealsLogged(entryCount),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(value == null ? '—' : '${value!.toStringAsFixed(0)}$unit',
                maxLines: 1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 5),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    )),
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({required this.totalMl, required this.onAdd});

  final int totalMl;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            const Icon(Icons.water_drop_outlined, size: 26),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.waterIntake,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text('$totalMl ml',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onAdd,
              child: Text(s.add250Ml),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMealsCard extends StatelessWidget {
  const _EmptyMealsCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Icon(Icons.restaurant_menu_outlined, size: 34),
            const SizedBox(height: 13),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 5),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    )),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAdd, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
