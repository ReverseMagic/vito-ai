import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemePreference { system, light, dark }

final appThemeProvider =
    NotifierProvider<AppThemeNotifier, AppThemePreference>(
  AppThemeNotifier.new,
);

class AppThemeNotifier extends Notifier<AppThemePreference> {
  @override
  AppThemePreference build() => AppThemePreference.system;

  void setPreference(AppThemePreference preference) => state = preference;
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) => state = locale;
}
