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
    return Scaffold(
      appBar: AppBar(title: Text(s.diary)),
      body: SafeArea(
        child: ref.watch(foodLogProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(s.dataLoadFailed, textAlign: TextAlign.center),
            ),
          ),
          data: (List<FoodEntry> entries) => entries.isEmpty
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
                          '${s.protein}: ${_format(entry.proteinGrams)}g · '
                          '${s.carbs}: ${_format(entry.carbsGrams)}g · '
                          '${s.fat}: ${_format(entry.fatGrams)}g\n'
                          '${s.sugar}: ${_format(entry.sugarTotalGrams)}g · '
                          '${s.fiber}: ${_format(entry.fiberGrams)}g · '
                          '${s.sodium}: ${_format(entry.sodiumMg)}mg',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('${entry.caloriesKcal} kcal'),
                            IconButton(
                              tooltip: s.removeEntry,
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(foodLogProvider.notifier)
                                      .remove(entry.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(s.entryRemoved)),
                                  );
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(s.saveFailed)),
                                  );
                                }
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-food'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _format(double? value) => value?.toStringAsFixed(0) ?? '—';
}
