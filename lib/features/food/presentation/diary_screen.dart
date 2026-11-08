import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/food_entry.dart';
import '../providers/food_log_provider.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final List<FoodEntry> entries = ref.watch(foodLogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.diary)),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.menu_book_outlined, size: 42),
                      const SizedBox(height: 16),
                      Text(s.noDiaryEntries,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(s.diaryEmptyDescription,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () => context.push('/add-food'),
                        child: Text(s.addFood),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 9),
                itemBuilder: (BuildContext context, int index) {
                  final FoodEntry entry = entries[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry.name),
                      subtitle: Text(
                        '${_format(entry.proteinGrams)}g ${s.protein.toLowerCase()} · '
                        '${_format(entry.carbsGrams)}g ${s.carbs.toLowerCase()} · '
                        '${_format(entry.fatGrams)}g ${s.fat.toLowerCase()}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('${entry.caloriesKcal} kcal'),
                          IconButton(
                            tooltip: s.removeEntry,
                            onPressed: () {
                              ref.read(foodLogProvider.notifier).remove(entry.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(s.entryRemoved)),
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-food'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _format(double? value) => value?.toStringAsFixed(0) ?? '—';
}
