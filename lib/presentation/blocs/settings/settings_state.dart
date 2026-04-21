import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool keepScreenOn;
  final bool fullScreen;
  final String arabicFontType;
  final double arabicFontSize;
  final bool tajwidColored;
  final bool tajwidGhunnah;
  final bool tajwidIkhfa;
  final bool tajwidIdgham;
  final bool tajwidIqlab;
  final bool tajwidQalqalah;
  final bool tajwidMadLazim;
  final bool showArabicNumbers;
  final bool showLatin;
  final double latinFontSize;
  final bool showTranslation;
  final double translationFontSize;
  final String translator;
  final int translatorId;
  final int selectedReciterId;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.keepScreenOn = false,
    this.fullScreen = false,
    this.arabicFontType = 'IndoPak',
    this.arabicFontSize = 28,
    this.tajwidColored = true,
    this.tajwidGhunnah = true,
    this.tajwidIkhfa = true,
    this.tajwidIdgham = true,
    this.tajwidIqlab = true,
    this.tajwidQalqalah = true,
    this.tajwidMadLazim = true,
    this.showArabicNumbers = true,
    this.showLatin = true,
    this.latinFontSize = 16,
    this.showTranslation = true,
    this.translationFontSize = 14,
    this.translator = 'Kemenag-RI',
    this.translatorId = 33,
    this.selectedReciterId = 5,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? keepScreenOn,
    bool? fullScreen,
    String? arabicFontType,
    double? arabicFontSize,
    bool? tajwidColored,
    bool? tajwidGhunnah,
    bool? tajwidIkhfa,
    bool? tajwidIdgham,
    bool? tajwidIqlab,
    bool? tajwidQalqalah,
    bool? tajwidMadLazim,
    bool? showArabicNumbers,
    bool? showLatin,
    double? latinFontSize,
    bool? showTranslation,
    double? translationFontSize,
    String? translator,
    int? translatorId,
    int? selectedReciterId,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    fullScreen: fullScreen ?? this.fullScreen,
    arabicFontType: arabicFontType ?? this.arabicFontType,
    arabicFontSize: arabicFontSize ?? this.arabicFontSize,
    tajwidColored: tajwidColored ?? this.tajwidColored,
    tajwidGhunnah: tajwidGhunnah ?? this.tajwidGhunnah,
    tajwidIkhfa: tajwidIkhfa ?? this.tajwidIkhfa,
    tajwidIdgham: tajwidIdgham ?? this.tajwidIdgham,
    tajwidIqlab: tajwidIqlab ?? this.tajwidIqlab,
    tajwidQalqalah: tajwidQalqalah ?? this.tajwidQalqalah,
    tajwidMadLazim: tajwidMadLazim ?? this.tajwidMadLazim,
    showArabicNumbers: showArabicNumbers ?? this.showArabicNumbers,
    showLatin: showLatin ?? this.showLatin,
    latinFontSize: latinFontSize ?? this.latinFontSize,
    showTranslation: showTranslation ?? this.showTranslation,
    translationFontSize: translationFontSize ?? this.translationFontSize,
    translator: translator ?? this.translator,
    translatorId: translatorId ?? this.translatorId,
    selectedReciterId: selectedReciterId ?? this.selectedReciterId,
  );

  @override
  List<Object?> get props => [
    themeMode,
    keepScreenOn,
    fullScreen,
    arabicFontType,
    arabicFontSize,
    tajwidColored,
    tajwidGhunnah,
    tajwidIkhfa,
    tajwidIdgham,
    tajwidIqlab,
    tajwidQalqalah,
    tajwidMadLazim,
    showArabicNumbers,
    showLatin,
    latinFontSize,
    showTranslation,
    translationFontSize,
    translator,
    translatorId,
    selectedReciterId,
  ];
}
