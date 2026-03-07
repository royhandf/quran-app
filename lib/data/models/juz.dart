import 'package:equatable/equatable.dart';

class Juz extends Equatable {
  final int id;
  final int juzNumber;
  final Map<String, String> verseMapping;
  final int versesCount;

  const Juz({
    required this.id,
    required this.juzNumber,
    required this.verseMapping,
    required this.versesCount,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    final rawMapping = json['verse_mapping'] as Map<String, dynamic>;
    final mapping = rawMapping.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return Juz(
      id: json['id'],
      juzNumber: json['juz_number'],
      verseMapping: mapping,
      versesCount: json['verses_count'],
    );
  }

  String getRangeText(Map<int, String> surahNames) {
    final keys = verseMapping.keys.toList();
    if (keys.isEmpty) return '';

    final firstSurahId = int.parse(keys.first);
    final lastSurahId = int.parse(keys.last);
    final firstRange = verseMapping[keys.first]!;
    final lastRange = verseMapping[keys.last]!;

    final firstName = surahNames[firstSurahId] ?? 'Surah $firstSurahId';
    final lastName = surahNames[lastSurahId] ?? 'Surah $lastSurahId';

    final firstAyah = firstRange.split('-').first;
    final lastAyah = lastRange.split('-').last;

    return '$firstName $firstAyah — $lastName $lastAyah';
  }

  @override
  List<Object?> get props => [id, juzNumber];
}
