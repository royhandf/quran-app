class Bookmark {
  final String id;
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'surahId': surahId,
    'surahName': surahName,
    'ayahNumber': ayahNumber,
    'ayahText': ayahText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromMap(Map<dynamic, dynamic> map) => Bookmark(
    id: map['id'] as String? ?? '',
    surahId: map['surahId'] as int? ?? 0,
    surahName: map['surahName'] as String? ?? '',
    ayahNumber: map['ayahNumber'] as int? ?? 0,
    ayahText: map['ayahText'] as String? ?? '',
    createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
        DateTime.now(),
  );
}
