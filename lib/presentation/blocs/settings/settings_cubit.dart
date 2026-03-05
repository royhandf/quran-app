import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/hive_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final HiveService _hiveService;

  SettingsCubit(this._hiveService) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final s = _hiveService.getAllSettings();
    emit(
      SettingsState(
        themeMode: _parseThemeMode(s['themeMode'] as String?),
        arabicFontType: s['arabicFontType'] as String? ?? 'IndoPak',
        arabicFontSize: (s['arabicFontSize'] as num?)?.toDouble() ?? 28,
        tajwidColored: s['tajwidColored'] as bool? ?? true,
        showArabicNumbers: s['showArabicNumbers'] as bool? ?? true,
        showLatin: s['showLatin'] as bool? ?? true,
        latinFontSize: (s['latinFontSize'] as num?)?.toDouble() ?? 16,
        showTranslation: s['showTranslation'] as bool? ?? true,
        translationFontSize:
            (s['translationFontSize'] as num?)?.toDouble() ?? 14,
        translator: s['translator'] as String? ?? 'Kemenag-RI',
      ),
    );
  }

  ThemeMode _parseThemeMode(String? v) => switch (v) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.dark,
  };

  void toggleTheme() {
    final m = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    _hiveService.saveSetting(
      'themeMode',
      m == ThemeMode.light ? 'light' : 'dark',
    );
    emit(state.copyWith(themeMode: m));
  }

  void setArabicFontType(String t) {
    _hiveService.saveSetting('arabicFontType', t);
    emit(state.copyWith(arabicFontType: t));
  }

  void setArabicFontSize(double s) {
    _hiveService.saveSetting('arabicFontSize', s);
    emit(state.copyWith(arabicFontSize: s));
  }

  void toggleTajwidColored(bool v) {
    _hiveService.saveSetting('tajwidColored', v);
    emit(state.copyWith(tajwidColored: v));
  }

  void toggleArabicNumbers(bool v) {
    _hiveService.saveSetting('showArabicNumbers', v);
    emit(state.copyWith(showArabicNumbers: v));
  }

  void toggleLatin(bool v) {
    _hiveService.saveSetting('showLatin', v);
    emit(state.copyWith(showLatin: v));
  }

  void setLatinFontSize(double s) {
    _hiveService.saveSetting('latinFontSize', s);
    emit(state.copyWith(latinFontSize: s));
  }

  void toggleTranslation(bool v) {
    _hiveService.saveSetting('showTranslation', v);
    emit(state.copyWith(showTranslation: v));
  }

  void setTranslationFontSize(double s) {
    _hiveService.saveSetting('translationFontSize', s);
    emit(state.copyWith(translationFontSize: s));
  }
}
