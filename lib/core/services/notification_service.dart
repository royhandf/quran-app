import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../../data/local/hive_service.dart';
import '../../data/models/prayer_time.dart';
import '../constants/prayer_alarm_ids.dart';

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

    const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_adzan');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Jadwalkan adzan untuk kemunculan hari ini (jika belum lewat) dan besok.
  /// Dua kemunculan menjaga alarm tetap berbunyi walau app tidak dibuka sehari.
  static Future<void> schedulePrayerAhead({
    required String prayerName,
    required String time,
  }) async {
    final parts = time.split(':');
    if (parts.length < 2) return;

    final now = DateTime.now();
    var first = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    final baseId = PrayerAlarmIds.forPrayer(prayerName);
    await _scheduleAt(id: baseId, prayerName: prayerName, when: first);
    await _scheduleAt(
      id: baseId + PrayerAlarmIds.nextDayOffset,
      prayerName: prayerName,
      when: first.add(const Duration(days: 1)),
    );
  }

  static Future<void> _scheduleAt({
    required int id,
    required String prayerName,
    required DateTime when,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: 'Waktu $prayerName',
      body: 'Sudah masuk waktu $prayerName',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
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

  /// Batalkan alarm hari ini dan besok untuk satu sholat.
  static Future<void> cancelPrayer(String prayerName) async {
    final baseId = PrayerAlarmIds.forPrayer(prayerName);
    await _plugin.cancel(id: baseId);
    await _plugin.cancel(id: baseId + PrayerAlarmIds.nextDayOffset);
  }

  /// Schedule semua sholat yang di-enable user, cancel yang di-disable.
  static Future<void> scheduleAllPrayers(
    List<PrayerItem> prayers,
    HiveService hiveService,
  ) async {
    for (final prayer in prayers) {
      // Terbit / Sunrise tidak perlu notifikasi
      if (prayer.name == 'Terbit' || prayer.name == 'Sunrise') continue;

      if (hiveService.isAlarmEnabled(prayer.name)) {
        await schedulePrayerAhead(
          prayerName: prayer.name,
          time: prayer.time,
        );
      } else {
        await cancelPrayer(prayer.name);
      }
    }
  }
}
