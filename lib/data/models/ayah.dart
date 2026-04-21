import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int id;
  final int verseNumber;
  final String textUthmani;
  final String textIndoPak;
  final String? textTranslation;
  final String? textTransliteration;

  const Ayah({
    required this.id,
    required this.verseNumber,
    required this.textUthmani,
    required this.textIndoPak,
    this.textTranslation,
    this.textTransliteration,
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
      textTransliteration: json['text_transliteration'] as String?,
    );
  }

  factory Ayah.fromEquranJson(Map<String, dynamic> json) {
    final teksArab = json['teksArab'] as String? ?? '';
    return Ayah(
      id: json['nomorAyat'] as int,
      verseNumber: json['nomorAyat'] as int,
      textUthmani: teksArab,
      textIndoPak: teksArab,
      textTranslation: json['teksIndonesia'] as String?,
      textTransliteration: json['teksLatin'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'verse_number': verseNumber,
    'text_uthmani': textUthmani,
    'text_imlaei': textIndoPak,
    'text_translation': textTranslation,
    'text_transliteration': textTransliteration,
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
