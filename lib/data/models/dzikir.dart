class DzikirCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final List<DzikirItem> items;

  const DzikirCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  factory DzikirCategory.fromJson(Map<String, dynamic> json) {
    return DzikirCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
      items: (json['items'] as List)
          .map((e) => DzikirItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DzikirItem {
  final int id;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
  final int count;

  const DzikirItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.count,
  });

  factory DzikirItem.fromJson(Map<String, dynamic> json) {
    return DzikirItem(
      id: json['id'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      source: json['source'] as String,
      count: json['count'] as int,
    );
  }
}
