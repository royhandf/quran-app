import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/data/models/prayer_time.dart';

void main() {
  group('PrayerTime', () {
    test('format 12 jam menangani tengah malam, siang, dan sore', () {
      expect(PrayerTime.to12Hour('00:10'), '12:10 AM');
      expect(PrayerTime.to12Hour('04:30'), '4:30 AM');
      expect(PrayerTime.to12Hour('12:05'), '12:05 PM');
      expect(PrayerTime.to12Hour('17:45'), '5:45 PM');
    });

    test('toList mengembalikan urutan waktu sholat yang benar', () {
      const time = PrayerTime(
        imsak: '04:20',
        fajr: '04:30',
        dhuhr: '12:00',
        asr: '15:15',
        maghrib: '18:00',
        isha: '19:10',
        sunrise: '05:55',
        date: '',
        hijriDate: '',
      );

      expect(
        time.toList().map((item) => item.name).toList(),
        ['Imsak', 'Subuh', 'Terbit', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'],
      );
    });
  });
}
