import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../../data/local/hive_service.dart';
import '../../data/models/prayer_time.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

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

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Schedule satu adzan. Jika waktu sudah lewat, schedule ke hari berikutnya.
  static Future<void> scheduleAdzan({
    required int id,
    required String prayerName,
    required String time,
  }) async {
    final parts = time.split(':');
    if (parts.length < 2) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // Kalau sudah lewat, jadwalkan hari berikutnya
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

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

  /// Schedule semua sholat yang di-enable user, cancel yang di-disable.
  static Future<void> scheduleAllPrayers(
    List<PrayerItem> prayers,
    HiveService hiveService,
  ) async {
    const nameToId = {
      'Fajr': 1, 'Sunrise': 2, 'Dhuhr': 3, 'Asr': 4, 'Maghrib': 5, 'Isha': 6,
      'Subuh': 1, 'Terbit': 2, 'Dzuhur': 3, 'Ashar': 4, 'Isya': 6,
    };

    for (final prayer in prayers) {
      // Terbit / Sunrise tidak perlu notifikasi
      if (prayer.name == 'Terbit' || prayer.name == 'Sunrise') continue;

      final id = nameToId[prayer.name] ?? prayer.name.hashCode.abs() % 100 + 10;
      final enabled = hiveService.isAlarmEnabled(prayer.name);

      if (enabled) {
        await scheduleAdzan(
          id: id,
          prayerName: prayer.name,
          time: prayer.time,
        );
      } else {
        await cancelAdzan(id);
      }
    }
  }

  static Future<void> cancelAdzan(int id) async {
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
