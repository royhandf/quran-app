import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String arabicFontType;
  final double arabicFontSize;
  final bool tajwidColored;
  final bool showArabicNumbers;
  final bool showLatin;
  final double latinFontSize;
  final bool showTranslation;
  final double translationFontSize;
  final String translator;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.arabicFontType = 'IndoPak',
    this.arabicFontSize = 28,
    this.tajwidColored = true,
    this.showArabicNumbers = true,
    this.showLatin = true,
    this.latinFontSize = 16,
    this.showTranslation = true,
    this.translationFontSize = 14,
    this.translator = 'Kemenag-RI',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? arabicFontType,
    double? arabicFontSize,
    bool? tajwidColored,
    bool? showArabicNumbers,
    bool? showLatin,
    double? latinFontSize,
    bool? showTranslation,
    double? translationFontSize,
    String? translator,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    arabicFontType: arabicFontType ?? this.arabicFontType,
    arabicFontSize: arabicFontSize ?? this.arabicFontSize,
    tajwidColored: tajwidColored ?? this.tajwidColored,
    showArabicNumbers: showArabicNumbers ?? this.showArabicNumbers,
    showLatin: showLatin ?? this.showLatin,
    latinFontSize: latinFontSize ?? this.latinFontSize,
    showTranslation: showTranslation ?? this.showTranslation,
    translationFontSize: translationFontSize ?? this.translationFontSize,
    translator: translator ?? this.translator,
  );

  @override
  List<Object?> get props => [
    themeMode,
    arabicFontType,
    arabicFontSize,
    tajwidColored,
    showArabicNumbers,
    showLatin,
    latinFontSize,
    showTranslation,
    translationFontSize,
    translator,
  ];
}
