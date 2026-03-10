import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int id;
  final int verseNumber;
  final String textUthmani;
  final String textIndoPak;
  final String? textTranslation;

  const Ayah({
    required this.id,
    required this.verseNumber,
    required this.textUthmani,
    required this.textIndoPak,
    this.textTranslation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    final uthmani = json['text_uthmani'] as String? ?? '';
    final indoPak = json['text_imlaei'] as String? ?? uthmani;
    return Ayah(
      id: json['id'],
      verseNumber: json['verse_number'],
      textUthmani: uthmani,
      textIndoPak: indoPak,
      textTranslation: _cleanHtml(
        json['translations']?.isNotEmpty == true
            ? json['translations'][0]['text']
            : json['text_translation'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'verse_number': verseNumber,
    'text_uthmani': textUthmani,
    'text_imlaei': textIndoPak,
    'text_translation': textTranslation,
  };

  @override
  List<Object?> get props => [id, verseNumber];

  static String? _cleanHtml(String? text) {
    if (text == null) return null;
    var cleaned = text.replaceAll(RegExp(r'<sup[^>]*>.*?</sup>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');
    return cleaned.trim();
  }
}
