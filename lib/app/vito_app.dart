import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/app_preferences_provider.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';

class VitoApp extends ConsumerWidget {
  const VitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemePreference themePreference = ref.watch(appThemeProvider);
    final Locale locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Vito AI',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (themePreference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      },
    );
  }
}
