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
      imsak: cleanTime(timings['Imsak'] ?? timings['Fajr']),
      fajr: cleanTime(timings['Fajr']),
      dhuhr: cleanTime(timings['Dhuhr']),
      asr: cleanTime(timings['Asr']),
      maghrib: cleanTime(timings['Maghrib']),
      isha: cleanTime(timings['Isha']),
      sunrise: cleanTime(timings['Sunrise']),
      date: date['readable'],
      hijriDate:
          '${date['hijri']['day']} ${date['hijri']['month']['en']} ${date['hijri']['year']}H',
    );
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
