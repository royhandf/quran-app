import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../../data/models/prayer_time.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    // DateTime.now().timeZoneName di Android mengembalikan singkatan
    // seperti "WIB", "WITA", "WIT" — bukan IANA timezone.
    // Mapping manual ke IANA agar notifikasi adzan tepat waktu.
    const tzAbbreviationMap = {
      'WIB': 'Asia/Jakarta',
      'WITA': 'Asia/Makassar',
      'WIT': 'Asia/Jayapura',
      'GMT+7': 'Asia/Jakarta',
      'GMT+8': 'Asia/Makassar',
      'GMT+9': 'Asia/Jayapura',
    };

    final String deviceTz = DateTime.now().timeZoneName;
    final String ianaTz = tzAbbreviationMap[deviceTz] ?? deviceTz;
    try {
      tz.setLocalLocation(tz.getLocation(ianaTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> scheduleAdzan({
    required int id,
    required String prayerName,
    required String time,
  }) async {
    final parts = time.split(':');
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    if (scheduledDate.isBefore(now)) return;

    await _plugin.zonedSchedule(
      id: id,
      title: 'Waktu $prayerName',
      body: 'Sudah masuk waktu $prayerName',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'adzan_channel',
          'Adzan',
          channelDescription: 'Notifikasi waktu sholat',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleAllPrayers(List<PrayerItem> prayers) async {
    const ids = {
      'Fajr': 1, 'Sunrise': 2, 'Dhuhr': 3,
      'Asr': 4, 'Maghrib': 5, 'Isha': 6,
      'Subuh': 1, 'Terbit': 2, 'Dzuhur': 3,
      'Ashar': 4, 'Isya': 6,
    };
    await _plugin.cancelAll();
    for (final prayer in prayers) {
      if (prayer.name == 'Terbit') continue;
      final id = ids[prayer.name] ?? prayer.name.hashCode.abs() % 100 + 10;
      await scheduleAdzan(
        id: id,
        prayerName: prayer.name,
        time: prayer.time,
      );
    }
  }

  static Future<void> cancelAdzan(int id) async {
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
