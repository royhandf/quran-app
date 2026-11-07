/// ID notifikasi adzan yang stabil lintas sesi.
///
/// Jangan memakai `String.hashCode` untuk ID: nilainya tidak dijamin stabil,
/// sehingga notifikasi lama tidak bisa dibatalkan setelah app dibuka ulang.
class PrayerAlarmIds {
  PrayerAlarmIds._();

  static const Map<String, int> byName = {
    'Imsak': 7,
    'Subuh': 1,
    'Terbit': 2,
    'Dzuhur': 3,
    'Ashar': 4,
    'Maghrib': 5,
    'Isya': 6,
    'Fajr': 1,
    'Sunrise': 2,
    'Dhuhr': 3,
    'Asr': 4,
    'Isha': 6,
  };

  /// Offset untuk kemunculan hari berikutnya.
  static const int nextDayOffset = 100;

  static int forPrayer(String name) => byName[name] ?? 99;
}
