import 'package:equatable/equatable.dart';

class PrayerTime extends Equatable {
  final String imsak;
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String sunrise;
  final String date;
  final String hijriDate;

  const PrayerTime({
    required this.imsak,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.date,
    required this.hijriDate,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final date = json['date'];
    String cleanTime(String time) =>
        time.replaceAll(RegExp(r'\s*\([^)]*\)'), '');

    return PrayerTime(
      imsak: cleanTime(timings['Imsak'] ?? timings['Fajr'] ?? ''),
      fajr: cleanTime(timings['Fajr'] ?? ''),
      dhuhr: cleanTime(timings['Dhuhr'] ?? ''),
      asr: cleanTime(timings['Asr'] ?? ''),
      maghrib: cleanTime(timings['Maghrib'] ?? ''),
      isha: cleanTime(timings['Isha'] ?? ''),
      sunrise: cleanTime(timings['Sunrise'] ?? ''),
      date: date['readable'] ?? '',
      hijriDate:
          '${date['hijri']?['day'] ?? ''} ${date['hijri']?['month']?['en'] ?? ''} ${date['hijri']?['year'] ?? ''}H',
    );
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  int getNextPrayerIndex() {
    final now = DateTime.now();
    final items = toList();
    for (int i = 0; i < items.length; i++) {
      if (_parseTime(items[i].time).isAfter(now)) return i;
    }
    return -1;
  }

  PrayerItem? getNextPrayer() {
    final idx = getNextPrayerIndex();
    if (idx == -1) return null;
    return toList()[idx];
  }

  Duration? getTimeUntilNextPrayer() {
    final idx = getNextPrayerIndex();
    if (idx == -1) return null;
    final items = toList();
    return _parseTime(items[idx].time).difference(DateTime.now());
  }

  static String to12Hour(String time24) {
    final parts = time24.split(':');
    if (parts.length < 2) return time24;
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }

  List<PrayerItem> toList() => [
    PrayerItem(name: 'Imsak', time: imsak),
    PrayerItem(name: 'Subuh', time: fajr),
    PrayerItem(name: 'Terbit', time: sunrise),
    PrayerItem(name: 'Dzuhur', time: dhuhr),
    PrayerItem(name: 'Ashar', time: asr),
    PrayerItem(name: 'Maghrib', time: maghrib),
    PrayerItem(name: 'Isya', time: isha),
  ];

  @override
  List<Object?> get props => [imsak, fajr, dhuhr, asr, maghrib, isha];
}

class PrayerItem {
  final String name;
  final String time;
  PrayerItem({required this.name, required this.time});
}
