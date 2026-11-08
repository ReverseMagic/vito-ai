import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/food/models/food_entry.dart';
import '../../../features/food/providers/food_log_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final DateTime now = DateTime.now();
    final List<FoodEntry> entries = ref.watch(foodLogProvider).where(
      (FoodEntry entry) =>
          entry.loggedAt.year == now.year &&
          entry.loggedAt.month == now.month &&
          entry.loggedAt.day == now.day,
    ).toList(growable: false);
    final int calories = entries.fold<int>(
      0,
      (int total, FoodEntry entry) => total + entry.caloriesKcal,
    );
    final double? protein = _completeTotal(entries, (FoodEntry e) => e.proteinGrams);
    final double? carbs = _completeTotal(entries, (FoodEntry e) => e.carbsGrams);
    final double? fat = _completeTotal(entries, (FoodEntry e) => e.fatGrams);

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
              Expanded(child: _MacroCard(label: s.protein, value: protein)),
              const SizedBox(width: 10),
              Expanded(child: _MacroCard(label: s.carbs, value: carbs)),
              const SizedBox(width: 10),
              Expanded(child: _MacroCard(label: s.fat, value: fat)),
            ],
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
  }

  double? _completeTotal(
    List<FoodEntry> entries,
    double? Function(FoodEntry) valueOf,
  ) {
    if (entries.isEmpty || entries.any((FoodEntry entry) => valueOf(entry) == null)) {
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

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(value == null ? '—' : '${value!.toStringAsFixed(0)}g',
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
