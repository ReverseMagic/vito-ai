import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/app_preferences_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final Locale locale = ref.watch(appLocaleProvider);
    final AppThemePreference theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.profile)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: <Widget>[
          Text(s.preferences,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.language, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'en', label: Text(s.english)),
                      ButtonSegment<String>(value: 'ar', label: Text(s.arabic)),
                    ],
                    selected: <String>{locale.languageCode},
                    onSelectionChanged: (Set<String> value) => ref
                        .read(appLocaleProvider.notifier)
                        .setLocale(Locale(value.first)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.appearance,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<AppThemePreference>(
                    segments: <ButtonSegment<AppThemePreference>>[
                      ButtonSegment(value: AppThemePreference.system, label: Text(s.system)),
                      ButtonSegment(value: AppThemePreference.light, label: Text(s.light)),
                      ButtonSegment(value: AppThemePreference.dark, label: Text(s.dark)),
                    ],
                    selected: <AppThemePreference>{theme},
                    onSelectionChanged: (Set<AppThemePreference> value) =>
                        ref.read(appThemeProvider.notifier).setPreference(value.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(s.productStatus, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 7),
          Text(s.productStatusDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  )),
        ],
      ),
    );
  }
}
