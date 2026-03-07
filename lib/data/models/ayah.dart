import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int id;
  final int verseNumber;
  final String textArabic;
  final String? textTranslation;

  const Ayah({
    required this.id,
    required this.verseNumber,
    required this.textArabic,
    this.textTranslation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      id: json['id'],
      verseNumber: json['verse_number'],
      textArabic: json['text_uthmani'] ?? json['text_imlaei'] ?? '',
      textTranslation: json['translations']?.isNotEmpty == true
          ? json['translations'][0]['text']
          : json['text_translation'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'verse_number': verseNumber,
    'text_uthmani': textArabic,
    'text_translation': textTranslation,
  };

  @override
  List<Object?> get props => [id, verseNumber];
}
