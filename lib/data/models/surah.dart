import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int id;
  final String nameArabic;
  final String nameSimple;
  final String translatedName;
  final int versesCount;
  final String revelationPlace;

  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.translatedName,
    required this.versesCount,
    required this.revelationPlace,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      nameArabic: json['name_arabic'],
      nameSimple: json['name_simple'],
      translatedName: json['translated_name']['name'],
      versesCount: json['verses_count'],
      revelationPlace: json['revelation_place'],
    );
  }

  @override
  List<Object?> get props => [id];
}
