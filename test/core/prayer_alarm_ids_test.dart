import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/constants/prayer_alarm_ids.dart';

void main() {
  test('setiap sholat punya ID tetap dan unik', () {
    const names = ['Imsak', 'Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    final ids = names.map(PrayerAlarmIds.forPrayer).toSet();
    expect(ids.length, names.length);
  });

  test('nama Inggris dan Indonesia memakai ID yang sama', () {
    expect(PrayerAlarmIds.forPrayer('Fajr'), PrayerAlarmIds.forPrayer('Subuh'));
    expect(PrayerAlarmIds.forPrayer('Isha'), PrayerAlarmIds.forPrayer('Isya'));
  });

  test('offset hari kedua berbeda dari hari pertama', () {
    for (final name in PrayerAlarmIds.byName.keys) {
      final base = PrayerAlarmIds.forPrayer(name);
      expect(base + PrayerAlarmIds.nextDayOffset, isNot(base));
    }
  });
}
