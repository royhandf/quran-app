import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/local/hive_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final HiveService _hiveService;

  SettingsCubit(this._hiveService) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final s = _hiveService.getAllSettings();
    final keepScreenOn = s['keepScreenOn'] as bool? ?? false;
    final fullScreen = s['fullScreen'] as bool? ?? false;

    WakelockPlus.toggle(enable: keepScreenOn);
    if (fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    emit(
      SettingsState(
        themeMode: _parseThemeMode(s['themeMode'] as String?),
        keepScreenOn: keepScreenOn,
        fullScreen: s['fullScreen'] as bool? ?? false,
        arabicFontType: s['arabicFontType'] as String? ?? 'IndoPak',
        arabicFontSize: (s['arabicFontSize'] as num?)?.toDouble() ?? 28,
        tajwidColored: s['tajwidColored'] as bool? ?? true,
        tajwidGhunnah: s['tajwidGhunnah'] as bool? ?? true,
        tajwidIkhfa: s['tajwidIkhfa'] as bool? ?? true,
        tajwidIdgham: s['tajwidIdgham'] as bool? ?? true,
        tajwidIqlab: s['tajwidIqlab'] as bool? ?? true,
        tajwidQalqalah: s['tajwidQalqalah'] as bool? ?? true,
        tajwidMadLazim: s['tajwidMadLazim'] as bool? ?? true,
        showArabicNumbers: s['showArabicNumbers'] as bool? ?? true,
        showLatin: s['showLatin'] as bool? ?? true,
        latinFontSize: (s['latinFontSize'] as num?)?.toDouble() ?? 16,
        showTranslation: s['showTranslation'] as bool? ?? true,
        translationFontSize:
            (s['translationFontSize'] as num?)?.toDouble() ?? 14,
        selectedReciterId: ((s['selectedReciterId'] as int?) ?? 5).clamp(1, 6),
      ),
    );
  }

  ThemeMode _parseThemeMode(String? v) => switch (v) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };

  String _themeModeToString(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  // === Umum ===
  void setThemeMode(ThemeMode mode) {
    _hiveService.saveSetting('themeMode', _themeModeToString(mode));
    emit(state.copyWith(themeMode: mode));
  }

  void toggleKeepScreenOn(bool v) {
    _hiveService.saveSetting('keepScreenOn', v);
    emit(state.copyWith(keepScreenOn: v));
    WakelockPlus.toggle(enable: v);
  }

  void toggleFullScreen(bool v) {
    _hiveService.saveSetting('fullScreen', v);
    emit(state.copyWith(fullScreen: v));
    if (v) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // === Arabic ===
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

  void toggleTajwidGhunnah(bool v) {
    _hiveService.saveSetting('tajwidGhunnah', v);
    emit(state.copyWith(tajwidGhunnah: v));
  }

  void toggleTajwidIkhfa(bool v) {
    _hiveService.saveSetting('tajwidIkhfa', v);
    emit(state.copyWith(tajwidIkhfa: v));
  }

  void toggleTajwidIdgham(bool v) {
    _hiveService.saveSetting('tajwidIdgham', v);
    emit(state.copyWith(tajwidIdgham: v));
  }

  void toggleTajwidIqlab(bool v) {
    _hiveService.saveSetting('tajwidIqlab', v);
    emit(state.copyWith(tajwidIqlab: v));
  }

  void toggleTajwidQalqalah(bool v) {
    _hiveService.saveSetting('tajwidQalqalah', v);
    emit(state.copyWith(tajwidQalqalah: v));
  }

  void toggleTajwidMadLazim(bool v) {
    _hiveService.saveSetting('tajwidMadLazim', v);
    emit(state.copyWith(tajwidMadLazim: v));
  }

  void toggleArabicNumbers(bool v) {
    _hiveService.saveSetting('showArabicNumbers', v);
    emit(state.copyWith(showArabicNumbers: v));
  }

  // === Latin ===
  void toggleLatin(bool v) {
    _hiveService.saveSetting('showLatin', v);
    emit(state.copyWith(showLatin: v));
  }

  void setLatinFontSize(double s) {
    _hiveService.saveSetting('latinFontSize', s);
    emit(state.copyWith(latinFontSize: s));
  }

  // === Terjemahan ===
  void toggleTranslation(bool v) {
    _hiveService.saveSetting('showTranslation', v);
    emit(state.copyWith(showTranslation: v));
  }

  void setTranslationFontSize(double s) {
    _hiveService.saveSetting('translationFontSize', s);
    emit(state.copyWith(translationFontSize: s));
  }

  // === Audio ===
  void setReciterId(int id) {
    _hiveService.saveSetting('selectedReciterId', id);
    emit(state.copyWith(selectedReciterId: id));
  }
}
